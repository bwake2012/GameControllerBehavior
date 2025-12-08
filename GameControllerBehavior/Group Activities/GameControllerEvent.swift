// GameControllerEvent.swift
//
// Created by Bob Wakefield on 1/15/22.
// for BotTime
//
// Using Swift 5.0
// Running on macOS 12.0
//
// Copyright © 2025 Cockleburr Software. All rights reserved.
//

import Foundation

enum GameControllerEvent {

    case gameController(String)

    case leftPadValueChanged(Float, Float)
    case rightPadValueChanged(Float, Float)

    case buttonAValueChanged(Float, Bool)
    case buttonBValueChanged(Float, Bool)
    case buttonXValueChanged(Float, Bool)
    case buttonYValueChanged(Float, Bool)

    var description: String {
        switch self {
        case .gameController(let vendor):
            return "Game controller:" + vendor
        case .leftPadValueChanged(let x, let y):
            return "left x:\(x) y:\(y)"
        case .rightPadValueChanged(let x, let y):
            return "right x:\(x) y:\(y)"

        case .buttonAValueChanged(let value, let pressed):
            return "A value:\(value) \(pressed ? "pressed" : "")"
        case .buttonBValueChanged(let value, let pressed):
            return "B value:\(value) \(pressed ? "pressed" : "")"
        case .buttonXValueChanged(let value, let pressed):
            return "X value:\(value) \(pressed ? "pressed" : "")"
        case .buttonYValueChanged(let value, let pressed):
            return "Y value:\(value) \(pressed ? "pressed" : "")"
        }
    }
}

extension GameControllerEvent: Encodable {}

extension GameControllerEvent: Decodable {}

extension GameControllerEvent: Equatable {}
