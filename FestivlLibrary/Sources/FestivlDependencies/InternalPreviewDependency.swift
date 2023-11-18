//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/22/23.
//

import Foundation
import Models
import Dependencies
import Utilities
import DependenciesMacros

@DependencyClient
public struct InternalPreviewClient {
    public var unlockInternalPreviews: (Event.ID) -> Void
    public var internalPreviewsAreUnlocked: (Event.ID) -> Bool = { _ in false }
}

private class InternalPreviewStore {
    
    @Storage(
        key: "unlockedEvents",
        defaultValue: .init(),
        transformation: .init(
            get: {
                Set($0.map { Event.ID($0)} )
                
            },
            set: { (unlocked: Set<Event.ID>) in
                unlocked.map { (value: Event.ID) in
                    value.rawValue
                }
            }
        )
    )
    static var unlockedEvents: Set<Event.ID>
}


extension InternalPreviewClient: DependencyKey {
    public static var liveValue: InternalPreviewClient {
        InternalPreviewClient(
            unlockInternalPreviews: { InternalPreviewStore.unlockedEvents.insert($0)  },
            internalPreviewsAreUnlocked: { InternalPreviewStore.unlockedEvents.contains($0) }
        )
    }

    public static var testValue: InternalPreviewClient = Self()
}

public extension DependencyValues {
    var internalPreviewClient: InternalPreviewClient {
        get { self[InternalPreviewClient.self] }
        set { self[InternalPreviewClient.self] = newValue }
    }
}
