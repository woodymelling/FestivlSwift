//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/6/22.
//

import Foundation
import Models
import IdentifiedCollections
import XCTestDynamicOverlay
import Dependencies
import Combine

public struct EventClient {
    public var getEvents: () -> DataStream<IdentifiedArrayOf<Event>>
    public var getEvent: (Event.ID) -> DataStream<Event>
}

public enum EventClientKey: TestDependencyKey {
    public static var testValue = EventClient(
        getEvents: XCTUnimplemented("EventClient.getEvents"),
        getEvent: XCTUnimplemented("EventClient.getEvent")
    )
    
    public static var previewValue = EventClient(
        getEvents: { Just(Event.testValues).eraseToAnyPublisher() },
        getEvent: { _ in Just(.testData).eraseToAnyPublisher() }
    )
}

public extension DependencyValues {
    var eventClient: EventClient {
        get { self[EventClientKey.self] }
        set { self[EventClientKey.self] = newValue }
    }
}


