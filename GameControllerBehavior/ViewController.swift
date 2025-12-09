// ViewController.swift
//
// Created by Bob Wakefield on 12/4/25.
// for GameControllerBehavior
//
// Using Swift 6.0
// Running on macOS 26.1
//
// 
//

import UIKit
import GroupActivities
import GameController

class ViewController: UIViewController {

    var faceTimeMonitor: FaceTimeMonitor?
    var groupActivitieHandler: GroupActivityHandler<GameControllerActivity, GameControllerMessage>?

    lazy var faceTimeLabel = buildLabel(text: "Group Activities:", textAlignment: .right)
    lazy var faceTimeStatus: UILabel = buildLabel(textAlignment: .left)
    lazy var faceTimeStack = buildStack(arrangedSubViews: [faceTimeLabel, faceTimeStatus])

    lazy var sharePlayStack = buildStack(arrangedSubViews: [faceTimeStack, sessionStartButton], axis: .vertical)

    lazy var actionSharePlayImage = UIImage(systemName: "shareplay")

    lazy var sessionStartAction = UIAction(title: "Start Session", image: actionSharePlayImage) { [weak self] action in

        self?.startSession()
    }

    func startSession() {

        DispatchQueue.main.async {
            guard
                let viewController = try? GroupActivitySharingController(GameControllerActivity())
            else { return }

            self.navigationController?.topViewController?.present(viewController, animated: true) {}
        }
    }

    lazy var sessionStartButton: UIButton = {
        let button = UIButton(primaryAction: sessionStartAction)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: .minTouchTarget),
        ])
        return button
    }()

    var connectedController: GCController?

    #if os(iOS)
    var virtualController: GCVirtualController?
    #endif

    var prepareToResize: Bool = false

    private var configurationElements: [String] =
    [
        GCInputRightThumbstick,
        GCInputButtonA,
        GCInputButtonB,
        GCInputButtonX
    ]

    lazy var connectAction = UIAction(title: "Connect Game Controller") { [weak self] _ in
        guard let self else { return }

        connectGameController()
        self.gameControllerConnectButton.isEnabled = false
    }

    func connectGameController() {
        self.setupGameControllerNotifications()

        UIView.animate(withDuration: 0.3) {
            self.setupGameController(parentView: self.view, virtual: false, controls: self.configurationElements)
        }
    }

    lazy var gameControllerConnectButton: UIButton = {
        let button = UIButton(primaryAction: connectAction)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: .minTouchTarget),
        ])
        return button
    }()

    lazy var gameControllerStatus: UILabel = buildLabel(text: "No Game Controller Connected", textAlignment: .center)

    lazy var leftJoyLabel = buildLabel(text: "Left Joystick:", textAlignment: .right)
    lazy var leftJoyStatus: UILabel = buildLabel(textAlignment: .left)
    lazy var leftJoyStack = buildStack(arrangedSubViews: [leftJoyLabel, leftJoyStatus])

    lazy var rightJoyLabel = buildLabel(text: "Right Joystick:", textAlignment: .right)
    lazy var rightJoyStatus: UILabel = buildLabel(textAlignment: .left)
    lazy var rightJoyStack = buildStack(arrangedSubViews: [rightJoyLabel, rightJoyStatus])

    lazy var aButtonLabel = buildLabel(text: "A Button:", textAlignment: .right)
    lazy var aButtonStatus: UILabel = buildLabel(textAlignment: .left)
    lazy var aButtonStack = buildStack(arrangedSubViews: [aButtonLabel, aButtonStatus])

    lazy var bButtonLabel = buildLabel(text: "B Button:", textAlignment: .right)
    lazy var bButtonStatus: UILabel = buildLabel(textAlignment: .left)
    lazy var bButtonStack = buildStack(arrangedSubViews: [bButtonLabel, bButtonStatus])

    lazy var xButtonLabel = buildLabel(text: "X Button:", textAlignment: .right)
    lazy var xButtonStatus: UILabel = buildLabel(textAlignment: .left)
    lazy var xButtonStack = buildStack(arrangedSubViews: [xButtonLabel, xButtonStatus])

    lazy var yButtonLabel = buildLabel(text: "Y Button:", textAlignment: .right)
    lazy var yButtonStatus: UILabel = buildLabel(textAlignment: .left)
    lazy var yButtonStack = buildStack(arrangedSubViews: [yButtonLabel, yButtonStatus])

    lazy var gameControllerStack: UIStackView = {

        let stackView = UIStackView(arrangedSubviews: [
            gameControllerStatus,
            leftJoyStack,
            rightJoyStack,
            aButtonStack,
            bButtonStack,
            xButtonStack,
            yButtonStack,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = .standardSpacing
        return stackView
    }()

    lazy var mainStack: UIStackView = {

        let stackView = UIStackView(arrangedSubviews: [
            sharePlayStack,
            gameControllerConnectButton,
            gameControllerStack,
         ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = .minTouchTarget / 2
        return stackView
    }()

    lazy var status: UILabel = buildLabel()

    private func buildLabel(text: String? = nil, textAlignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    private func buildStack(arrangedSubViews: [UIView], axis: NSLayoutConstraint.Axis = .horizontal) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.distribution = .fillEqually
        stackView.spacing = .standardSpacing
        return stackView
    }

    override func loadView() {
        super.loadView()

        view.addSubview(mainStack)
        status.setContentHuggingPriority(.required, for: .vertical)
        view.addSubview(status)

        view.backgroundColor = .systemBackground

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .horizontalMargin),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: .horizontalMargin),
            status.topAnchor.constraint(greaterThanOrEqualTo: mainStack.bottomAnchor, constant: .standardSpacing),
            status.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .horizontalMargin),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: status.trailingAnchor, constant: .horizontalMargin),
            status.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        view.layoutIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        faceTimeMonitor = FaceTimeMonitor(delegate: self)
        groupActivitieHandler = GroupActivityHandler<GameControllerActivity, GameControllerMessage>(activity: GameControllerActivity(), delegate: self)
        groupActivitieHandler?.beginWaitingForSessions()

        debugLog(Bundle.main.appVersionString ?? "Unknown Version!")
    }
}

extension ViewController: GameControllerAdapterProtocol {

    func updateGameControllerStatus() {
        sendGameController(
            event: .gameController(
                connectedController?.vendorName ?? "None"
            )
        )
    }

    func leftPadValueChanged(pad: GCControllerDirectionPad, xValue: Float, yValue: Float) {
        let v = (1 - abs(xValue)) * yValue + yValue
        let w = (1 - abs(yValue)) * xValue + xValue

        let leftValue = (v + w) / 2
        let rightValue = (v - w) / 2

        sendGameController(event: .leftPadValueChanged(leftValue, rightValue))
    }
    
    func rightPadValueChanged(pad: GCControllerDirectionPad, xValue: Float, yValue: Float) {
        let v = (1 - abs(xValue)) * yValue + yValue
        let w = (1 - abs(yValue)) * xValue + xValue

        let leftValue = (v + w) / 2
        let rightValue = (v - w) / 2

        sendGameController(event: .rightPadValueChanged(leftValue, rightValue))
    }
    
    func buttonAValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        sendGameController(event: .buttonAValueChanged(value, pressed))
    }
    
    func buttonBValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        sendGameController(event: .buttonBValueChanged(value, pressed))
    }
    
    func buttonXValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        sendGameController(event: .buttonXValueChanged(value, pressed))
    }
    
    func buttonYValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        sendGameController(event: .buttonYValueChanged(value, pressed))
    }

    func debugLog(_ text: String) {
#if DEBUG
        print(text)
#endif
        DispatchQueue.main.async {
            self.status.text = text
        }
    }
}

extension ViewController: FaceTimeMonitorDelegate {

    func canConnect(_ canConnect: Bool) {
        faceTimeStatus.text = canConnect ? "Eligible" : "Ineligible"
        print("Group Activities:\(canConnect ? "Eligible" : "Ineligible")")
    }
}

extension ViewController: GroupActivityHandlerDelegate {

    func didConnect() {
        debugLog("Connected")

        let version: (Int, Int, Int, Int) = Bundle.main.appVersion
        groupActivitieHandler?.send(
            message: GameControllerMessage(
                service: .version(
                    version.0, version.1, version.3
                )
            )
        )
    }

    func didDisconnect() {
        debugLog("Disconnected")
    }
    
    func participantsChanged(count: Int) {
        debugLog("Participants: \(count)")
    }
    
    func session(status: String) {
        debugLog("Session Status: \(status)")
    }
    
    func update<M>(message: M) where M : GroupActivityMessage {
        guard
            let message = message as? GameControllerMessage
        else {
            assertionFailure("Unknown message type: \(message.description)")
            return
        }

        switch message.service {
        case .version(let major, let minor, let build):
            debugLog("Version: \(major).\(minor)  b\(build)")
        case .gameControllerEvent(let event):
            displayGameController(event: event)
            debugLog("Event: \(event.description)")
        }
    }
    
    func report(error: any Error) {
        debugLog("Report: \(error)")
    }

    private func sendGameController(event: GameControllerEvent) {
        groupActivitieHandler?.send(
            message: GameControllerMessage(
                service: .gameControllerEvent(event)
            )
        )
    }
}

extension ViewController {

    func displayGameController(event: GameControllerEvent) {
        switch event {

        case .gameController(let vendor):
            displayGameControllerStatus(vendor)

        case .leftPadValueChanged(let leftValue, let rightValue):
            displayLeftPadValue(leftValue, rightValue)

        case .rightPadValueChanged(let leftValue, let rightValue):
            displayRightPadValue(leftValue, rightValue)

        case .buttonAValueChanged(let value, let pressed):
            displayButtonAValue(value, pressed)

        case .buttonBValueChanged(let value, let pressed):
            displayButtonBValue(value, pressed)

        case .buttonXValueChanged(let value, let pressed):
            displayButtonXValue(value, pressed)

        case .buttonYValueChanged(let value, let pressed):
            displayButtonYValue(value, pressed)
        }
    }

    func displayGameControllerStatus(_ vendor: String) {
        gameControllerStatus.text = vendor
    }

    func displayLeftPadValue(_ leftValue: Float, _ rightValue: Float) {
        leftJoyStatus.text = "\(leftValue), \(rightValue)"
    }

    func displayRightPadValue(_ leftValue: Float, _ rightValue: Float) {
        rightJoyStatus.text = "\(leftValue), \(rightValue)"
    }

    func displayButtonAValue(_ value: Float, _ pressed: Bool) {
        aButtonStatus.text = pressed ? "Pressed \(value)" : "Not Pressed"
    }

    func displayButtonBValue(_ value: Float, _ pressed: Bool) {
        bButtonStatus.text = pressed ? "Pressed \(value)" : "Not Pressed"
    }

    func displayButtonXValue(_ value: Float, _ pressed: Bool) {
        xButtonStatus.text = pressed ? "Pressed \(value)" : "Not Pressed"
    }

    func displayButtonYValue(_ value: Float, _ pressed: Bool) {
        yButtonStatus.text = pressed ? "Pressed \(value)" : "Not Pressed"
    }
}

#if canImport(SwiftUI) && DEBUG

import SwiftUI

@available(iOS 17, *)
#Preview {

    ViewController(nibName: nil, bundle: nil)
}

#endif
