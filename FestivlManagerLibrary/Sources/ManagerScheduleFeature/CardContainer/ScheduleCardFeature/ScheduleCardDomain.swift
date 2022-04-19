//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/1/22.
//

import Foundation
import ComposableArchitecture
import Models
import Services

public struct ScheduleCardState: Equatable, Identifiable {
    var set: ScheduleItem
    var stage: Stage
    let event: Event

    public var id: String? {
        return set.id
    }
}

struct ScheduleCardEnvironment {
    var artistSetService: () -> ScheduleServiceProtocol

    public init(
        artistSetService: @escaping () -> ScheduleServiceProtocol = { ScheduleService.shared }
    ) {
        self.artistSetService = artistSetService
    }
}

public enum ScheduleCardAction {
    case didTap
    case didDrag(newEndTime: Date)
    case didFinishDragging
    case didFinishSavingDrag
}

let scheduleCardReducer = Reducer<ScheduleCardState, ScheduleCardAction, ScheduleCardEnvironment> { state, action, environment in
    switch action {
    case .didTap:
        return .none
    case .didDrag(let newEndTime):
        state.set.endTime = newEndTime.round(precision: 5.minutes)
        return .none
    case .didFinishDragging:
        // Handled above
        return .none
        
    case .didFinishSavingDrag:
        return .none
    }

}


