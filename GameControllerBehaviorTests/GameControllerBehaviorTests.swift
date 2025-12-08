// GameControllerBehaviorTests.swift
//
// Created by Bob Wakefield on 12/4/25.
// for GameControllerBehavior
//
// Using Swift 6.0
// Running on macOS 26.1
//
// 
//

import Foundation

import Testing
@testable import GameControllerBehavior

struct GameControllerBehaviorTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test func leftPadValueChangedEncode() {

        let encoded = GameControllerEvent.buttonAValueChanged(1.0, true)

        let encoder = JSONEncoder()

        let data = try? encoder.encode(encoded)

        guard let data else {
            #expect(data != nil, "Data encoded unsuccessfully!")
            return
        }

        let decoder = JSONDecoder()

        let decoded = try? decoder.decode(GameControllerEvent.self, from: data)

        #expect(encoded == decoded)
    }

//    @Test func rightPadValueChangedEncode() {
//
//        #expect(encoded == decoded)
//    }
//
//    @Test func buttonAValueChanged() {
//
//        #expect(encoded == decoded)
//    }
//
//    @Test func buttonBValueChanged√() {
//
//        #expect(encoded == decoded)
//    }
//
//    @Test func buttonXValueChanged() {
//
//        #expect(encoded == decoded)
//    }
//
//    @Test func buttonYValueChanged() {
//
//        #expect(encoded == decoded)
//    }


}
