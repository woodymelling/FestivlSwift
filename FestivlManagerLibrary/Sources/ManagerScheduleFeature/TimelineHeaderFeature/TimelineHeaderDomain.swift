//
// TimelineHeaderDomain.swift
//
//
//  Created by Woody on 3/29/2022.
//

import ComposableArchitecture
import Models

public struct TimelineHeaderState: Equatable {
    @BindableState var selectedDate: Date
    let stages: IdentifiedArrayOf<Stage>
    let festivalDates: [Date]
}

public enum TimelineHeaderAction: BindableAction {
    case binding(_ action: BindingAction<TimelineHeaderState>)
}

public struct TimelineHeaderEnvironment {
    public init() {}
}

public let timelineHeaderReducer = Reducer<TimelineHeaderState, TimelineHeaderAction, TimelineHeaderEnvironment> { state, action, _ in
    return .none
}
.binding()
