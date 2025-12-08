// FaceTimeMonitor.swift
//
// Created by Bob Wakefield on 10/23/21.
// for StateMachine
//
// Using Swift 5.0
// Running on macOS 11.6
//
// 
//

import Foundation
import Combine
import GroupActivities

protocol FaceTimeMonitorDelegate: AnyObject {

    func canConnect(_ canConnect: Bool)
}

/// Set up an observer for whether or not we have a FaceTime connection.
class FaceTimeMonitor: NSObject {

    private weak var delegate: FaceTimeMonitorDelegate?

    lazy private var faceTimeStateObserver = GroupStateObserver()
    private var faceTimeStateTask: AnyCancellable?

    var canConnect: Bool {
        faceTimeStateObserver.isEligibleForGroupSession
    }

    deinit {

        faceTimeStateTask?.cancel()
    }

    init(delegate: FaceTimeMonitorDelegate) {

        self.delegate = delegate

        super.init()

        faceTimeStateTask =
            faceTimeStateObserver.$isEligibleForGroupSession.sink { [weak self] isElegibleForGroupSession in

                self?.delegate?.canConnect(isElegibleForGroupSession)
            }
    }
}

