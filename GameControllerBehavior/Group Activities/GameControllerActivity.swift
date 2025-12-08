//
//  BotTimeActivity.swift
//  GroupActivitiesExerciser
//
//  Created by Bob Wakefield on 6/10/21.
//

import GroupActivities
import UIKit

struct GameControllerActivity: GroupActivity {

    // specify the activity type to the system
    static let activityIdentifier = "net.cockleburr.gamecontrollerbehavior.services"

    // provide information about the activity
    var metadata: GroupActivityMetadata {

        var metadata = GroupActivityMetadata()

        metadata.type = .generic
        metadata.title = NSLocalizedString("GameControllerBehavior by Bob Wakefield", comment: "")
        metadata.subtitle = NSLocalizedString("Send game controller events over a FaceTime call.", comment: "")

        metadata.previewImage = UIImage(named: "SplashIcon")?.cgImage

        return metadata
    }
}

extension GameControllerActivity: Equatable {}
