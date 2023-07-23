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
        getData: {
            @Dependency(\.eventID) var eventID
            
            return Publishers.CombineLatest4(
                EventClientKey.liveValue.getEvent(),
                StageClientKey.liveValue.getStages(),
                ArtistClientKey.liveValue.getArtists(),
                ScheduleClientKey.liveValue.getSchedule()
            )
            .map { event, stages, artists, schedule in
                EventData(event: event, stages: stages, artists: artists, schedule: schedule)
            }
            .share()
            .eraseToAnyPublisher()
        }
    )
}
