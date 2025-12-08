// GameControllerAdapterProtocol.swift
//
// Created by Bob Wakefield on 1/1/22.
// for MinimumVirtualGameControllerV2
//
// Using Swift 5.0
// Running on macOS 12.0
//
// 
//

import UIKit
import GameController

protocol GameControllerAdapterProtocol: AnyObject {

    var prepareToResize: Bool { get set }

    var connectedControllerIsVirtual: Bool { get }

    var connectedController: GCController? { get set }
#if os(iOS)
    var virtualController: GCVirtualController? { get set }
#endif

    func setupGameControllerNotifications()
    func setupGameController(parentView: UIView, virtual: Bool, controls: [String])
    func takedownGameController()
    func hideVirtualGameController(prepareToResize: Bool)
    func showVirtualGameController()
    func updateGameControllerStatus()

    func findVirtualGameAdapterView(completion: (UIView?) -> Void)

    func leftPadValueChanged(pad: GCControllerDirectionPad, xValue: Float, yValue: Float)
    func rightPadValueChanged(pad: GCControllerDirectionPad, xValue: Float, yValue: Float)

    func buttonAValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void
    func buttonBValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void
    func buttonXValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void
    func buttonYValueChanged(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void

    func debugLog(_ message: String)
}

extension GameControllerAdapterProtocol {

    var connectedControllerIsVirtual: Bool {
        let controllerIsConnected = nil != connectedController
#if os(iOS)
        let controllerIsVirtualController = connectedController === virtualController?.controller
#else
        let controllerIsVirtualController = false
#endif
        debugLog("connectedControllerIsVirtual: controllerConnected:\(controllerIsConnected) && controllerIsVirtualController:\(controllerIsVirtualController)")
        return controllerIsConnected && controllerIsVirtualController
    }

    func setupGameControllerNotifications() {

        NotificationCenter.default.addObserver(forName: .GCControllerDidBecomeCurrent, object: nil, queue: nil, using: handleControllerDidConnect(_:))

        NotificationCenter.default.addObserver(forName: .GCControllerDidStopBeingCurrent, object: nil, queue: nil, using: handleControllerDidDisconnect(_:))
    }
    
    func setupGameController(parentView view: UIView, virtual: Bool = false, controls: [String]) {

#if iOS
        if virtual {

            let virtualControllerNeeded = GCController.controllers().isEmpty
            debugLog("setupGameController \(virtualControllerNeeded ? "Empty" : "Not Empty")")

            let virtualConfiguration = GCVirtualController.Configuration()
            virtualConfiguration.elements = Set<String>(controls)
            virtualController = GCVirtualController(configuration: virtualConfiguration)

            // Connect to the virtual controller if no physical controllers are available.
            if virtualControllerNeeded {

                virtualController?.connect()
            }
        }
#endif

        guard let controller = GCController.controllers().first else {
            return
        }

        if #available(iOS 18.0, visionOS 2.0, *), !virtual {

            let interaction = GCEventInteraction()
            interaction.handledEventTypes = .gamepad

            view.addInteraction(interaction)
        }

        registerGameController(controller)
    }

    func takedownGameController() {
#if os(iOS)
        debugLog("takedownGameController virtual controller \(nil != virtualController ? "Present" : "Not Present")")
        virtualController?.disconnect()
        virtualController = nil
#endif
    }

    func showVirtualGameController() {

#if os(iOS)
        debugLog(
            "showVirtualGameController connectedController:\(nil != self.connectedController ? "Present" : "Not Present") " +
            "virtualController:\(nil != virtualController ? "Present" : "Not Present")")
        if nil == self.connectedController {

            UIView.animate(withDuration: 0.3) {
                self.virtualController?.connect()
            }
        }
#endif
        self.updateGameControllerStatus()
    }

    func hideVirtualGameController(prepareToResize: Bool = false) {

#if os(iOS)
        debugLog("hideVirtualGameController prepareToResize:\(prepareToResize) connected controller \(self.connectedControllerIsVirtual ? "is virtual" : "is not virtual")")

        if self.connectedControllerIsVirtual {
            self.prepareToResize = prepareToResize

            UIView.animate(withDuration: 0.3) {
                self.virtualController?.disconnect()
            }
        }
#endif
        self.updateGameControllerStatus()
    }

    func handleControllerDidConnect(_ notification: Notification) {

        guard let gameController = notification.object as? GCController else
        {
            return
        }

#if os(iOS)
        if !gameController.isAppleController
        {
            virtualController?.disconnect()
        }
#endif
        registerGameController(gameController)

        connectedController = gameController

        updateGameControllerStatus()
    }

    func handleControllerDidDisconnect(_ notification: Notification) {

        connectedController = nil

        guard let gameController = notification.object as? GCController else
        {
            return
        }

        unregisterGameController()

        let controllers = GCController.controllers()
        debugLog("handleControllerDidDisconnect: controller count:\(controllers.count)")

#if os(iOS)
        if controllers.isEmpty && !gameController.isAppleController
        {
            virtualController?.connect()
        }
#endif

        updateGameControllerStatus()

        if prepareToResize {

            DispatchQueue.main.async {

                self.prepareToResize = false
                self.showVirtualGameController()
            }
        }
    }

    // Connect the real or virtual game pad buttons and thumbsticks to the app
    func registerGameController(_ gameController: GCController) {

        var leftJoystick: GCControllerDirectionPad?
        var rightJoystick: GCControllerDirectionPad?

        var buttonA: GCControllerButtonInput?
        var buttonB: GCControllerButtonInput?

        var buttonX: GCControllerButtonInput?
        var buttonY: GCControllerButtonInput?

        if let gamePad = gameController.extendedGamepad
        {
            buttonA = gamePad.buttonA
            buttonB = gamePad.buttonB

            buttonX = gamePad.buttonX
            buttonY = gamePad.buttonY

            leftJoystick = gamePad.leftThumbstick
            rightJoystick = gamePad.rightThumbstick
        }

        buttonA?.valueChangedHandler = self.buttonAValueChanged(_:_:_:)

        buttonB?.valueChangedHandler = self.buttonBValueChanged(_:_:_:)

        buttonX?.valueChangedHandler = self.buttonXValueChanged(_:_:_:)

        buttonY?.valueChangedHandler = self.buttonYValueChanged(_:_:_:)

        leftJoystick?.valueChangedHandler = self.leftPadValueChanged(pad:xValue:yValue:)
        rightJoystick?.valueChangedHandler = self.rightPadValueChanged(pad:xValue:yValue:)
    }

    func unregisterGameController() {

    }

    func findVirtualGameAdapterView(completion: (UIView?) -> Void) -> Void {

        if connectedControllerIsVirtual {

            let keyWindow =
                UIApplication
                    .shared
                    .connectedScenes
                    .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                    .first { $0.isKeyWindow }

            if let rootView = keyWindow?.rootViewController?.view {

                rootView.findSubview(
                    matchesCriteria: { view in

                        return String(describing: view).hasPrefix("<GCControllerView: ")
                    },
                    completion: { view in

                        completion(view)
                   })
            }
        }
    }
}

extension GCController {
    var isAppleController: Bool {
        let vendorPrefix = "Apple"
        return vendorName?.prefix(vendorPrefix.count) ?? "" == vendorPrefix
    }
}
