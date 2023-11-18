//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/7/22.
//

import Foundation
import Models
import Dependencies
import Utilities
import Tagged

public enum UserDefaultsDependencyKey: DependencyKey {
    public static var liveValue: UserDefaultStore = UserDefaultStore.shared
}

public class UserDefaultStore {
    public static var shared = UserDefaultStore()
    
    @Storage(key: "hasDisplayedTutorialElements", defaultValue: false)
    public var hasShownScheduleTutorial: Bool
}

public enum OrganizationIDDependencyKey: DependencyKey {
    public static var liveValue: Organization.ID = unimplemented("Accessed EventID before it has been set")
    public static var testValue: Organization.ID = unimplemented("OrganizationID not set")
    public static var previewValue: Organization.ID = ""
}

public enum EventIDDependencyKey: DependencyKey {
    public static var liveValue: Event.ID = "" // unimplemented("Accessed EventID before it has been set")
    public static var testValue: Event.ID = unimplemented("EventID not set")
    public static var previewValue: Event.ID = ""
}


public enum IsEventSpecificApplicationDependencyKey: DependencyKey {
    public static var liveValue = true
}

public extension DependencyValues {
    var userDefaults: UserDefaultStore {
        get { self[UserDefaultsDependencyKey.self] }
        set { self[UserDefaultsDependencyKey.self] = newValue }
    }
    
    var isEventSpecificApplication: Bool {
        get { self[IsEventSpecificApplicationDependencyKey.self] }
        set { self[IsEventSpecificApplicationDependencyKey.self] = newValue }
    }
    
    var eventID: Event.ID {
        get { self[EventIDDependencyKey.self] }
        set { self[EventIDDependencyKey.self] = newValue }
    }

    var organizationID: Organization.ID {
        get { self[OrganizationIDDependencyKey.self] }
        set { self[OrganizationIDDependencyKey.self] = newValue }
    }
}


