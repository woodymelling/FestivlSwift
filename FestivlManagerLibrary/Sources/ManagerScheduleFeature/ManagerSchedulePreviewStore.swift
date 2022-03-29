//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/29/22.
//

import Foundation
import ComposableArchitecture
import Models

extension Store where State == ManagerScheduleState, Action == ManagerScheduleAction {
    static var previewStore: Store<ManagerScheduleState, ManagerScheduleAction> {
        return .init(
            initialState: .init(
                event: .testData,
                selectedDate: Event.testData.festivalDates.first!,
                zoomAmount: 1,
                artists: Artist.testValues.asIdentifedArray,
                stages: Stage.testValues.asIdentifedArray,
                artistSets: ArtistSet.testValues(startTime: Event.testData.festivalDates.first!).asIdentifedArray
            ),
            reducer: managerScheduleReducer,
            environment: .init()
        )
    }
}
