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
import DependenciesMacros
import Combine
import Tagged
import Utilities

@DependencyClient
public struct EventClient {
    public var getPublicEvents: () -> DataStream<IdentifiedArrayOf<Event>> = { Empty().eraseToDataStream() }
    public var getEvent: () -> DataStream<Event> = { Empty().eraseToDataStream() }
    public var getMyEvents: () -> DataStream<Event> = { Empty().eraseToDataStream() }

    public var createEvent: (
        _ name: String,
        _ startDate: CalendarDate,
        _ endDate: CalendarDate,
        _ dayStartsAtNoon: Bool,
        _ timeZone: TimeZone,
        _ imageURL: URL?
    ) async throws -> (Event.ID)

    public var editEvent: (Event) async throws -> Void
}

extension EventClient: TestDependencyKey {
    public static var testValue: EventClient = Self()

    public static var previewValue = EventClient(
        getPublicEvents: {
            .just(InMemoryEventService.shared.events)
        },
        getEvent: { .just(Event.previewData) },
        getMyEvents: { .just(Event.previewData) },
        createEvent: { name, startDate, endDate, dayStartsAtNoon, timeZone, imageURL in
            try await InMemoryEventService.shared.createEvent(
                Event(
                    id: "",
                    name: name,
                    startDate: startDate,
                    endDate: endDate,
                    dayStartsAtNoon: dayStartsAtNoon,
                    timeZone: timeZone
                )
            )
        },
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
        get { self[EventClient.self] }
        set { self[EventClient.self] = newValue }
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

