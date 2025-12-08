//
//  NSBundle+AppVersion.swift
//  OpenLibrary & BotTime
//
//  Created by Bob Wakefield on 9/16/16.
//  Copyright © 2016 Bob Wakefield. All rights reserved.
//

import Foundation

extension Bundle {
    
    var appVersionString: String? {

        // First get the nsObject by defining as an optional anyObject
        guard
            let infoDictionary = Bundle.main.infoDictionary,
            
            let tempVersion = infoDictionary["CFBundleShortVersionString"] as AnyObject?,
            let tempBuild = infoDictionary["CFBundleVersion"] as AnyObject?,
            
            // Then just cast the object as a String, but be careful, you may want to double check for nil
            let version = tempVersion as? String,
            let build = tempBuild as? String
        else {
            return nil
        }

        return "\(version) (\(build))"
    }

    var appVersion: (Int, Int, Int, Int) {
        guard
            let infoDictionary = Bundle.main.infoDictionary,

            let tempVersion = infoDictionary["CFBundleShortVersionString"] as AnyObject?,
            let tempBuild = infoDictionary["CFBundleVersion"] as AnyObject?,
            // Then just cast the object as a String, but be careful, you may want to double check for nil
            let stringVersion = tempVersion as? String,
            let stringBuild = tempBuild as? String
        else {
            return (0, 0, 0, 0)
        }

        let versionParts = stringVersion.split(separator: ".").map { Int($0) }
        let build = Int(stringBuild) ?? 0

        var major: Int = 0
        var minor: Int = 0
        var patch: Int = 0

        if versionParts.count > 0 {
            major = versionParts[0] ?? 0
        }
        if versionParts.count > 1 {
            minor = versionParts[1] ?? 0
        }
        if versionParts.count > 2 {
            patch = versionParts[2] ?? 0
        }

        return (major, minor, patch, build)
    }
}
