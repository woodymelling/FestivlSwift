//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/29/22.
//

import Foundation
import ComposableArchitecture
import Models
import Utilities

extension Store where State == ManagerScheduleState, Action == ManagerScheduleAction {
    static var previewStore: Store<ManagerScheduleState, ManagerScheduleAction> {

        let startTime = Event.testData.festivalDates.first!.startOfDay(dayStartsAtNoon: Event.testData.dayStartsAtNoon)
        return .init(
            initialState: .init(
                event: .testData,
                selectedDate: Event.testData.festivalDates.first!,
                zoomAmount: 1,
                artists: Artist.testValues.asIdentifedArray,
                stages: Stage.testValues.asIdentifedArray,
                schedule: .init(artistSets: ArtistSet.testValues(startTime: startTime).asIdentifedArray, groupSets: .init()),
                liveSchedule: .init(artistSets: ArtistSet.testValues(startTime: startTime).asIdentifedArray, groupSets: .init()),
                addEditArtistSetState: nil,
                artistSearchText: ""
            ),
            reducer: managerScheduleReducer,
            environment: .init(artistSetService: { PublishableScheduleService(schedule: .init(artistSets: .init(), groupSets: .init())) })

        )
    }
}
