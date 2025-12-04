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
import GameController

class ViewController: UIViewController {

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

    lazy var connectAction = UIAction(title: "Connect Game Controller") { _ in
        self.setupGameControllerNotifications()

        UIView.animate(withDuration: 0.3) {
            self.setupGameController(parentView: self.view, virtual: false, controls: self.configurationElements)
        }

        self.gameControllerConnectButton.isEnabled = false
    }

    lazy var gameControllerConnectButton: UIButton = {
        let button = UIButton(primaryAction: connectAction)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: .minTouchTarget),
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
            gameControllerConnectButton,
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
        stackView.spacing = 8
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
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    private func buildStack(arrangedSubViews: [UIView], axis: NSLayoutConstraint.Axis = .horizontal) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }

    override func loadView() {
        super.loadView()

        view.addSubview(gameControllerStack)
        status.setContentHuggingPriority(.required, for: .vertical)
        view.addSubview(status)

        view.backgroundColor = .systemBackground

        NSLayoutConstraint.activate([
            gameControllerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            gameControllerStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .horizontalMargin),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: gameControllerStack.trailingAnchor, constant: .horizontalMargin),
            status.topAnchor.constraint(greaterThanOrEqualTo: gameControllerStack.bottomAnchor, constant: .standardSpacing),
            status.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .horizontalMargin),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: status.trailingAnchor, constant: .horizontalMargin),
            status.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        view.layoutIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        status.text = "General Status"
    }
}

extension ViewController: GameControllerAdapterProtocol {

    func updateGameControllerStatus() {
        gameControllerStatus.text = connectedController?.vendorName ?? "None"
    }

    func leftPadValueChanged(pad: GCControllerDirectionPad, xValue: Float, yValue: Float) {
        let v = (1 - abs(xValue)) * yValue + yValue
        let w = (1 - abs(yValue)) * xValue + xValue

        let leftValue = (v + w) / 2
        let rightValue = (v - w) / 2

        leftJoyStatus.text = "\(leftValue), \(rightValue)"
    }
    
    func rightPadValueChanged(pad: GCControllerDirectionPad, xValue: Float, yValue: Float) {
        let v = (1 - abs(xValue)) * yValue + yValue
        let w = (1 - abs(yValue)) * xValue + xValue

        let leftValue = (v + w) / 2
        let rightValue = (v - w) / 2

        rightJoyStatus.text = "\(leftValue), \(rightValue)"
    }
    
    func buttonAValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        aButtonStatus.text = pressed ? "Pressed \(value)" : "Not Pressed"
    }
    
    func buttonBValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        bButtonStatus.text = pressed ? "Pressed \(value)" : "Not Pressed"
    }
    
    func buttonXValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        xButtonStatus.text = pressed ? "Pressed \(value)" : "Not Pressed"
    }
    
    func buttonYValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
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
