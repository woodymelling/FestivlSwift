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
import XCTestDynamicOverlay
import Combine

public struct EventData: Equatable {
    public init(
        event: Event,
        stages: IdentifiedArrayOf<Stage>,
        artists: IdentifiedArrayOf<Artist>,
        schedule: Schedule
    ) {
        self.event = event
        self.stages = stages
        self.artists = artists
        self.schedule = schedule
    }
    
    public var event: Event
    public var stages: IdentifiedArrayOf<Stage>
    public var artists: IdentifiedArrayOf<Artist>
    public var schedule: Schedule
}

public struct AllEventDataClient {
    public init(getData: @escaping (Event.ID) -> DataStream<EventData>) {
        self.getData = getData
    }
    
    public var getData: (Event.ID) -> DataStream<EventData>
}

public enum AllEventDataClientKey: TestDependencyKey {
    public static var testValue = AllEventDataClient(
        getData: XCTUnimplemented("AllEventDataClient.getData")
    )
    
    public static var previewValue = AllEventDataClient(
        getData: { eventID in
            Publishers.CombineLatest4(
                EventClientKey.previewValue.getEvent(eventID),
                StageClientKey.previewValue.getStages(eventID),
                ArtistClientKey.previewValue.getArtists(eventID),
                ScheduleClientKey.previewValue.getSchedule(eventID)
            )
            .map { event, stages, artists, schedule in
                EventData(event: event, stages: stages, artists: artists, schedule: schedule)
            }
            .eraseToAnyPublisher()
        }
    )
}

public extension DependencyValues {
    var eventDataClient: AllEventDataClient {
        get { self[AllEventDataClientKey.self] }
        set { self[AllEventDataClientKey.self] = newValue }
    }
}
