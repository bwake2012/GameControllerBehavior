// GroupSession.State+description.swift
//
// Created by Bob Wakefield on 10/24/21.
// for BotTime
//
// Using Swift 5.0
// Running on macOS 11.6
//
// Copyright © 2021 Cockleburr Software. All rights reserved.
//

import Foundation

import GroupActivities

extension GroupSession.State {

    var description: String {
        switch self {

        case .waiting:
            return "waiting"
        case .joined:
            return "joined"
        case .invalidated(reason: let reason):
            return "invalidated: \(reason.localizedDescription)"
        @unknown default:
            return "Unknown GroupSession state!"
        }
    }
}
