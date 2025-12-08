//
//  GroupActivityHandler.swift
//  BotTime
//
//  Created by Bob Wakefield on 6/12/21.
//

import Foundation
import Combine
import GroupActivities

typealias ParticipantID = UUID

protocol GroupActivityMessage: Codable {

    var id: UUID { get }
    var timestamp: Date { get }
    var participantID: ParticipantID { get }
    var description: String { get }

    init(participantID: ParticipantID, service: GameControllerEventService)
}

/// Contains the setup and session logic for GroupActivities.
class GroupActivityHandler<GA: GroupActivity, GM: GroupActivityMessage>: NSObject {

    enum GroupActivityHandlerError: Error {

        case noSession
        case attemptToJoinNilSession
        case attemptToUseNilMessenger
        case messageSendFail(Error)
        case messagePastSellByDate(GM)

        var localizedDescription: String {

            switch self {
            case .noSession:
                return "No Group Session."
            case .attemptToJoinNilSession:
                return "Attempted to join a nonexistent session."
            case .attemptToUseNilMessenger:
                return "Attempted to send a message using a nonexistent messenger."
            case .messageSendFail(let error):
                return "Activity message send failure: \(error.localizedDescription)"
            case .messagePastSellByDate(let message):
                return "Message past its sell-by date: \(message.description)"
            }
        }
    }

    var uuid = UUID()
    var hostTypeName: String { "\(Self.self)" }

    weak var groupActivityHandlerDelegate: GroupActivityHandlerDelegate?

    var isConnected: Bool {

        return .joined == (groupSession?.state ?? .invalidated(reason: GroupActivityHandlerError.noSession))
    }

    var participantCount: Int {

        return groupSession?.activeParticipants.count ?? 0
    }

    private var sessionListenerTask: Task<(), Never>?

    private var tasks = Set<Task<(), Never>>()

    private var messenger: GroupSessionMessenger?

    private var groupSession: GroupSession<GA>?

    private var latestTimestamp = Date.distantPast

    private var subscriptions = Set<AnyCancellable>()

    private var activity: GA?

    /// Create the activity handler
    init(activity: GA, delegate: GroupActivityHandlerDelegate? = nil) {

        super.init()

        self.activity = activity
        self.groupActivityHandlerDelegate = delegate
    }

    deinit {

        sessionListenerTask?.cancel()
    }

    func activate() {

        guard let activity = self.activity else {
            preconditionFailure("Attempt to activate misconfigured group activity!")
        }

        // let's not try to activate a session if we already have one.
        guard nil == self.groupSession else { return }

        Task {
            do {
                _ = try await activity.activate()
            }
            catch {
                groupActivityHandlerDelegate?.report(error: error)
            }
        }

        return
    }

    func leaveSession() {

        // tear down existing group session
        if groupSession?.activeParticipants.count == 1 {
            groupSession?.end()
        } else {
            groupSession?.leave()
        }

        teardown()
    }

    func endSession() {

        // tear down existing group session
        groupSession?.end()

        teardown()
    }

    private func teardown() {

        latestTimestamp = Date.distantPast
        groupSession = nil

        messenger = nil
        tasks.forEach { $0.cancel() }
        tasks = []
        subscriptions = []
    }

    /// Wait for sessions to connect
    func beginWaitingForSessions() {

        sessionListenerTask =
            Task { [weak self] in

                for await session in GA.sessions() {

                    self?.configure(session)
                }
            }
    }

    private func report(error: GroupActivityHandlerError) {

        groupActivityHandlerDelegate?.report(error: error)
    }

    private func configure(_ groupSession: GroupSession<GA>) {

        self.groupSession = groupSession

        subscriptions.removeAll()

        groupSession.$state.sink { [weak self] state in

            guard let self = self else { return }

            switch state {
            case .waiting:
                break
            case .joined:
                self.groupActivityHandlerDelegate?.didConnect()
            case .invalidated(reason: let reason):
                self.groupSession = nil
                self.teardown()
                self.groupActivityHandlerDelegate?.didDisconnect()
                self.groupActivityHandlerDelegate?.report(error: reason)
            @unknown default:
                break
            }

            self.groupActivityHandlerDelegate?.session(status: state.description)
        }
        .store(in: &subscriptions)

        groupSession.join()

        groupSession.$activeParticipants
            .sink { [weak self] activeParticipants in

                self?.groupActivityHandlerDelegate?.participantsChanged(count: activeParticipants.count)
            }
            .store(in: &subscriptions)

        if #available(iOS 16, *) {
            self.messenger = GroupSessionMessenger(session: groupSession, deliveryMode: .reliable)
        } else {
            self.messenger = GroupSessionMessenger(session: groupSession)
        }

        configure(messenger)
    }

    /// Add a task to wait for messages for other devices in the session
    /// and pass them on to the delegate.
    private func configure(_ messenger: GroupSessionMessenger?) {

        guard nil != messenger else { return }

        let task = Task.detached { [weak self] in

            guard let messenger = self?.messenger else { return }

            for await (message, _) in messenger.messages(of: GM.self) {

                self?.handle(message)
            }
        }

        tasks.insert(task)
    }

    /// Forward a message from another device in the session to the delegate.
    /// - Parameter message: Message received from the other device. Must conform
    /// to the GroupActivityMessage protocol, with a unique ID and timestamp.
    private func handle(_ message: GM) {

        latestTimestamp = message.timestamp
        groupActivityHandlerDelegate?.update(message: message)
    }

    /// Pass a message to the other devices in this session. Report any error to the delegate.
    /// - Parameter message: The structure to be passed.
    func send(message: GM) {

        guard nil != messenger else {

            debugLog("Attempt to send a message through a nil messenger!")
            groupActivityHandlerDelegate?.report(error: GroupActivityHandlerError.attemptToUseNilMessenger)
            return
        }

        Task {

            do {

                try await messenger?.send(message)

            } catch {

                groupActivityHandlerDelegate?.report(error: GroupActivityHandlerError.messageSendFail(error))
            }
        }
    }
}

extension GroupActivityHandler {

    func send(service: GameControllerEventService) {

        guard let participantID = groupSession?.localParticipant.id
        else {
            return
        }

        send(message: GM(participantID: participantID, service: service))
    }
}
