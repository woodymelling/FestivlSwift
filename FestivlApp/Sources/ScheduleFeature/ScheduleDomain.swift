//
//  Schedule.swift
//
//
//  Created by Woody on 2/17/2022.
//

import ComposableArchitecture
import CoreGraphics
import Models
import ArtistPageFeature

public struct ScheduleState: Equatable {
    public init(
//        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        schedule: Schedule,
        selectedStage: Stage,
        event: Event,
        zoomAmount: CGFloat = 1,
        selectedDate: Date,
        cardToDisplay: AnyStageScheduleCardRepresentable?,
        selectedArtistState: ArtistPageState?
    ) {
        self.stages = stages
        self.event = event
        self.zoomAmount = zoomAmount
        self.selectedStage = selectedStage
        self.selectedDate = selectedDate
        self.schedule = schedule
        self.cardToDisplay = cardToDisplay
    }

    public var schedule: Schedule
    public let artists: IdentifiedArrayOf<Artist> = .init()
    public let stages: IdentifiedArrayOf<Stage>
    public var event: Event

    public var zoomAmount: CGFloat = 1
    @BindableState public var selectedStage: Stage
    public var selectedDate: Date

    public var cardToDisplay: AnyStageScheduleCardRepresentable?
}

public enum ScheduleAction: BindableAction {
    case zoomed(CGFloat)
    case binding(_ action: BindingAction<ScheduleState>)
    case selectedDate(Date)

    case showAndHighlightCard(AnyStageScheduleCardRepresentable)
    case highlightCard(AnyStageScheduleCardRepresentable)
    case unHilightCard

    case didTapCard(AnyStageScheduleCardRepresentable)
}

public struct ScheduleEnvironment {
    public init() {}
}

public let scheduleReducer = Reducer<ScheduleState, ScheduleAction, ScheduleEnvironment> { state, action, _ in
    switch action {
    case .binding:
        return .none

    case .zoomed(let amount):
        if amount > 1 {
            state.zoomAmount = amount
        }
        return .none

    case .selectedDate(let date):
        state.selectedDate = date
        return .none

    case .showAndHighlightCard(let card):
        if let stage = state.stages[id: card.stageID] {
            state.selectedStage = stage
        }

        state.selectedDate = card.startTime.startOfDay(dayStartsAtNoon: state.event.dayStartsAtNoon)

        return .asyncTask {
            try! await Task.sleep(nanoseconds: 100_000_000)

            // Need to set cardToDisplay after a delay, otherwise the onChange and scrollTo combination won't work
            return .highlightCard(card)
        }
        .receive(on: DispatchQueue.main)
        .eraseToEffect()

    case .highlightCard(let card):
        state.cardToDisplay = card
        return Effect(value: .unHilightCard)
            .delay(for: 1, scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main.animation(.easeOut(duration: 1)))
            .eraseToEffect()

    case .unHilightCard:
        state.cardToDisplay = nil

        return .none

    case .didTapCard(let card):

        switch card.type {
        case .artistSet(let artistID):
            guard let artist = state.artists[id: artistID] else { return .none }

            return .none

        case .groupSet:
            return .none
        }

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
                schedule: .init(),
                selectedStage: Stage.testValues[0],
                event: .testData,
                selectedDate: time,
                cardToDisplay: nil,
                selectedArtistState: nil
            ),
            reducer: scheduleReducer,
            environment: .init()
        )
    }
}
