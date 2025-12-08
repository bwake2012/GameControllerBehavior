// GameControllerEventService.swift
//
// Created by Bob Wakefield on 7/17/21.
// for GroupActivitiesExerciser
//
// Using Swift 5.0
// Running on macOS 11.4
//
// Copyright © 2021 Cockleburr Software. All rights reserved.
//

import Foundation

enum GameControllerEventService: Equatable, Encodable, Decodable {

    case version(Int, Int, Int)
    case gameControllerEvent(GameControllerEvent)

    var description: String {
        switch self {
        case .version(let major, let minor, let build):
            return "GameControllerBehavior \(major).\(minor) B\(build)"
        case .gameControllerEvent(let event): return "Command \(event.description)"
        }
    }
}
