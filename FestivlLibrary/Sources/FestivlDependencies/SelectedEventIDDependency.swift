//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/7/22.
//

import Foundation
import Models
import Dependencies

public enum EventIDDependencyKey: DependencyKey {
    public static var liveValue: EventIDStore = EventIDStore.shared
}

public class EventIDStore {
    static var shared = EventIDStore()
    
    public var value: Event.ID {
        get { .init(UserDefaults.standard.string(forKey: "savedEventID") ?? "") }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "savedEventID") }
    }
}



public enum IsEventSpecificApplicationDependencyKey: DependencyKey {
    public static var liveValue = false
}

public extension DependencyValues {
    var eventID: EventIDStore {
        get { self[EventIDDependencyKey.self] }
        set { self[EventIDDependencyKey.self] = newValue }
    }
    
    var isEventSpecificApplication: Bool {
        get { self[IsEventSpecificApplicationDependencyKey.self] }
        set { self[IsEventSpecificApplicationDependencyKey.self] = newValue }
    }
}


