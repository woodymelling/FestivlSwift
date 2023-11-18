//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/23/22.
//

import Foundation
import Models
import IdentifiedCollections
import Dependencies
import DependenciesMacros
import XCTestDynamicOverlay
import Combine
import CustomDump

public struct EventData: Equatable {
    
    public init(
        event: Event,
        stages: IdentifiedArrayOf<Stage>,
        artists: IdentifiedArrayOf<Artist>,
        schedule: Schedule
    ) {
        
        @Dependency(\.internalPreviewClient) var internalPreviewClient
        
        self.event = event
        self.stages = stages
        self.artists = artists
        
        if event.scheduleIsPublished || internalPreviewClient.internalPreviewsAreUnlocked(event.id) {
            self.schedule = schedule
        } else {
            self.schedule = .init(scheduleItems: [], dayStartsAtNoon: event.dayStartsAtNoon, timeZone: event.timeZone)
        }
    }
    
    public var event: Event
    public var stages: IdentifiedArrayOf<Stage>
    public var artists: IdentifiedArrayOf<Artist>
    public var schedule: Schedule
}

@DependencyClient
public struct AllEventDataClient {
    public var getData: () -> DataStream<EventData> = { Empty().eraseToDataStream() }
}


extension EventData: CustomDumpStringConvertible {
    public var customDumpDescription: String {
        return "EventData(...)"
    }
}


extension AllEventDataClient: TestDependencyKey {
    public static var testValue = Self()
    
    public static var liveValue = AllEventDataClient(
        getData: {
            @Dependency(\.eventID) var eventID

            @Dependency(\.artistClient) var artistClient
            @Dependency(\.eventClient) var eventClient
            @Dependency(\.scheduleClient) var scheduleClient
            @Dependency(\.stageClient) var stageClient

            return Publishers.CombineLatest4(
                eventClient.getEvent(),
                stageClient.getStages(),
                artistClient.getArtists(),
                scheduleClient.getSchedule()
            )
            .map { event, stages, artists, schedule in
                EventData(event: event, stages: stages, artists: artists, schedule: schedule)
            }
            .share()
            .eraseToAnyPublisher()
        }
    )
}

public extension DependencyValues {
    var eventDataClient: AllEventDataClient {
        get { self[AllEventDataClient.self] }
        set { self[AllEventDataClient.self] = newValue }
    }
}
