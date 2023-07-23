//
//  File.swift
//  
//
//  Created by Woodrow Melling on 9/27/22.
//

import Foundation
import Dependencies
import UserNotifications

public enum UNUserNotificationCenterKey: DependencyKey {
    public static let liveValue = UNUserNotificationCenter.current
}

public extension DependencyValues {
    var userNotificationCenter: () -> UNUserNotificationCenter {
        get { self[UNUserNotificationCenterKey.self] }
        set { self[UNUserNotificationCenterKey.self] = newValue }
    }
}
