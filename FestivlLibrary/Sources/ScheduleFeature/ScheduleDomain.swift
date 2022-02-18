//
//  Schedule.swift
//
//
//  Created by Woody on 2/17/2022.
//

import ComposableArchitecture
import CoreGraphics
import Models

public struct ScheduleState: Equatable {
    internal init(stages: IdentifiedArrayOf<Stage>, selectedStage: Stage, event: Event, zoomAmount: CGFloat = 1, selectedDate: Date) {
        self.stages = stages
        self.event = event
        self.zoomAmount = zoomAmount
        self.selectedStage = selectedStage
        self.selectedDate = selectedDate
    }

    public var stages: IdentifiedArrayOf<Stage>
    public var event: Event

    public var zoomAmount: CGFloat = 1
    @BindableState public var selectedStage: Stage
    public var selectedDate: Date
}

public enum ScheduleAction: BindableAction {
    case zoomed(CGFloat)
    case binding(_ action: BindingAction<ScheduleState>)
    case selectedDate(Date)
}

public struct ScheduleEnvironment {
    public init() {}
}

public let scheduleReducer = Reducer<ScheduleState, ScheduleAction, ScheduleEnvironment> { state, action, _ in
    switch action {
    case .zoomed(let amount):
        if amount > 1 {
            state.zoomAmount = amount
        }
        return .none

    case .selectedDate(let date):
        state.selectedDate = date
        return .none
        
    case .binding:
        return .none
    }
}
.binding()
