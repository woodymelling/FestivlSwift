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
import Tagged
import Utilities

public struct EventClient {
    public init(
        getEvents: @escaping () -> DataStream<IdentifiedArrayOf<Event>>,
        getEvent: @escaping () -> DataStream<Event>,
        getMyEvents: @escaping () -> DataStream<Event>,
        createEvent: @escaping (Event) async throws -> (Event.ID),
        editEvent: @escaping (Event) async throws -> Void
    ) {
        self.getPublicEvents = getEvents
        self.getEvent = getEvent
        self.getMyEvents = getMyEvents
        self.createEvent = createEvent
        self.editEvent = editEvent
    }
    
    public var getPublicEvents: () -> DataStream<IdentifiedArrayOf<Event>>
    public var getEvent: () -> DataStream<Event>
    
    public var getMyEvents: () -> DataStream<Event>
    public var createEvent: (Event) async throws -> (Event.ID)
    public var editEvent: (Event) async throws -> Void
}

public enum EventClientKey: TestDependencyKey {
    public static var testValue = EventClient(
        getEvents: unimplemented("EventClient.getEvents"),
        getEvent: unimplemented("EventClient.getMyEvents"),
        getMyEvents: unimplemented("EventClient.getEvent"),
        createEvent: unimplemented("EventClient.createEvent"),
        editEvent: unimplemented("EventClient.editEvent")
    )
    
    public static var previewValue = EventClient(
        getEvents: { .just(InMemoryEventService.shared.events) },
        getEvent: { .just(Event.previewData) },
        getMyEvents: { .just(Event.previewData) },
        createEvent: { return try await InMemoryEventService.shared.createEvent($0) },
        editEvent: {
            if let event = InMemoryEventService.shared.events[id: $0.id] {
                InMemoryEventService.shared.events[id: $0.id] = $0
            } else {
                throw FestivlError.default(description: "Not Found")
            }
            
        }
    )
}

public extension DependencyValues {
    var eventClient: EventClient {
        get { self[EventClientKey.self] }
        set { self[EventClientKey.self] = newValue }
    }
}

// MARK: - InMemoryEventService

class InMemoryEventService {
    
    static var shared = InMemoryEventService()
    
    var events: IdentifiedArrayOf<Event> = [Event.previewData] 
    
    func createEvent(_ event: Event) async throws -> Event.ID {
        var event = event
        event.id = .init(UUID().uuidString)
        events.append(event)
        return event.id
    }
}




extension Event {
    public func dateForCalendarAtLaunch(selectedDate: CalendarDate?) -> CalendarDate {
        
        @Dependency(\.date) var todaysDate
        
        if let currentlySelectedDate = selectedDate, dateRange.contains(currentlySelectedDate) {
            return currentlySelectedDate
        }
        
        let today: CalendarDate
        
        if dayStartsAtNoon {
            today = CalendarDate(date: todaysDate() - 12.hours)
        } else{
            today = CalendarDate(date: todaysDate())
        }
        
        
        if self.festivalDates.contains(today) {
            return today
        } else if today < startDate {
            return startDate
        } else {
            return festivalDates.last ?? endDate.adding(days: -1)
        }
    }
}

