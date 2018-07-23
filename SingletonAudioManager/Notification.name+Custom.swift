//
//  Notification.name+Custom.swift
//  SingletonAudioManager
//
//  Created by 이광용 on 2018. 7. 23..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation

extension Notification.Name {
    static func get(_ name: NotificationNames) -> Notification.Name {
        return Notification.Name(name.description)
    }
}

enum NotificationNames {
    case audioManager
    var description: String {
        switch self {
        case .audioManager:
            return "AudioManagerNotification"
        }
    }
}
