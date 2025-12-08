// GameControllerMessage.swift
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

struct GameControllerMessage: GroupActivityMessage {

    static let dateFormatter = ISO8601DateFormatter()

    static let participantID = UUID()

    let participantID: ParticipantID

    let id: UUID
    let timestamp: Date

    let service: GameControllerEventService

    init(participantID: ParticipantID = Self.participantID, service: GameControllerEventService) {

        self.participantID = participantID
        self.id = UUID()
        self.timestamp = Date()

        self.service = service
    }

    var description: String {

        return "\(participantID.uuidString) \(Self.dateFormatter.string(from: timestamp)) \(id.uuidString) \(service.description)"
    }
}

extension GameControllerMessage: Codable {

    enum CodableKeys: String, CodingKey, CaseIterable {
        case participantID, id, timestamp, service
    }

    init(from decoder: any Decoder) throws {

        let values = try decoder.container(keyedBy: CodableKeys.self)

        do {
            participantID = try values.decode(UUID.self, forKey: .participantID)
            id = try values.decode(UUID.self, forKey: .id)
            timestamp = try values.decode(Date.self, forKey: .timestamp)

            service = try values.decode(GameControllerEventService.self, forKey: .service)

        } catch let error as DecodingError {
            preconditionFailure(error.prettyDescription)
        }
    }
}
