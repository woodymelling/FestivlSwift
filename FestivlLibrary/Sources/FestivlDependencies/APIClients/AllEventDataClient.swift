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

public struct AllEventDataClient {
    public init(getData: @escaping () -> DataStream<EventData>) {
        self.getData = getData
    }
    
    public var getData: () -> DataStream<EventData>
}


extension EventData: CustomDumpStringConvertible {
    public var customDumpDescription: String {
        return "EventData(...)"
    }
}


public enum AllEventDataClientKey: TestDependencyKey {
    public static var testValue = AllEventDataClient(
        getData: XCTUnimplemented("AllEventDataClient.getData")
    )
    
    public static var previewValue = AllEventDataClient(
        getData: {            
            return Publishers.CombineLatest4(
                EventClientKey.previewValue.getEvent(),
                StageClientKey.previewValue.getStages(),
                ArtistClientKey.previewValue.getArtists(),
                ScheduleClientKey.previewValue.getSchedule()
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
