// GroupActivityHandlerDelegate.swift
//
// Created by Bob Wakefield on 4/23/22.
// for BotTime
//
// Using Swift 5.0
// Running on macOS 12.3
//
// Copyright © 2022 Cockleburr Software. All rights reserved.
//

import Foundation

protocol GroupActivityHandlerDelegate: AnyObject {

    func didConnect()
    func didDisconnect()
    func participantsChanged(count: Int)
    func session(status: String)
    func update<M: GroupActivityMessage>(message: M)
    func report(error: Error)
}
