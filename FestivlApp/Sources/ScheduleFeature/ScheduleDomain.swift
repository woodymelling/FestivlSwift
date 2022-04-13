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
    public init(
        stages: IdentifiedArrayOf<Stage>,
        artistSets: IdentifiedArrayOf<ArtistSet>,
        groupSets: IdentifiedArrayOf<GroupSet>,
        selectedStage: Stage,
        event: Event,
        zoomAmount: CGFloat = 1,
        selectedDate: Date,
        scrollAmount: CGPoint = .zero
    ) {
        self.stages = stages
        self.event = event
        self.zoomAmount = zoomAmount
        self.selectedStage = selectedStage
        self.selectedDate = selectedDate
        self.scrollAmount = scrollAmount

        self.scheduleCards = (artistSets.map { $0.asAnyStageScheduleCardRepresentable() } + groupSets.map { $0.asAnyStageScheduleCardRepresentable() }).asIdentifedArray
    }

    public var scheduleCards: IdentifiedArrayOf<AnyStageScheduleCardRepresentable>
    public var stages: IdentifiedArrayOf<Stage>
    public var event: Event

    public var zoomAmount: CGFloat = 1
    @BindableState public var selectedStage: Stage
    public var selectedDate: Date
    @BindableState public var scrollAmount: CGPoint

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



extension Store where State == ScheduleState, Action == ScheduleAction {
    static var testStore: Store<ScheduleState, ScheduleAction> {
        let time = Event.testData.festivalDates[0]
        return Store(
            initialState: .init(
                stages: Stage.testValues.asIdentifedArray,
                artistSets: ArtistSet.testValues(startTime: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: time)!).asIdentifedArray,
                groupSets: .init(),
                selectedStage: Stage.testValues[0],
                event: .testData,
                selectedDate: time
            ),
            reducer: scheduleReducer,
            environment: .init()
        )
    }
}
