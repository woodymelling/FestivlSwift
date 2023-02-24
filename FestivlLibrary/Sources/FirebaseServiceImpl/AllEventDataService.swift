//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/24/22.
//

import Foundation
import FestivlDependencies
import Dependencies
import Combine

extension AllEventDataClientKey: DependencyKey {
    public static var liveValue = AllEventDataClient(
        getData: { eventID in
            Publishers.CombineLatest4(
                EventClientKey.liveValue.getEvent(eventID),
                StageClientKey.liveValue.getStages(eventID),
                ArtistClientKey.liveValue.getArtists(eventID),
                ScheduleClientKey.liveValue.getSchedule(eventID)
            )
            .map { event, stages, artists, schedule in
                EventData(event: event, stages: stages, artists: artists, schedule: schedule)
            }
            .eraseToAnyPublisher()
        }
    )
}
