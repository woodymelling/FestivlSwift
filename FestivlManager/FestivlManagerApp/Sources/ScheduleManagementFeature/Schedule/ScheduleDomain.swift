//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/4/23.
//

import Foundation
import ComposableArchitecture
import FestivlDependencies
import Models
import Utilities
import Dependencies
import Tagged


/**
 ScheduleDomain holds onto the state of the schedule. It has a page which holds onto stages. ScheduleDomain only passes the sets for the day is selected to each stage.
 We derive the current schedule page from stages, and a dictionary which goes from CalendarDate -> [StageID: [Cards]].
 This dictionary is the schedule for each day, indexed by stage within each day.
 This process of deriving the state *should* be O(n) based on the number of stages, not great, but never too bad.
 
 Creating the schedule domain is where the complexity happens, but it really should just be O(n) based on the number of sets.
 */
public struct ScheduleDomain: Reducer {
    @Dependency(\.scheduleClient) var scheduleClient
    @Dependency(\.stageClient) var stageClient
    
    public struct State: Equatable {
        @BindingState var selectedDate: CalendarDate
        var stages: Stages
        var event: Event
        
        var cardsPerDay: [CalendarDate : [Stage.ID : IdentifiedArrayOf<ScheduleCardDomain.State>]] // This could be moved to schedule and have an index get made.
        
        var schedulePageState: SchedulePageDomain.State {
            get {
                SchedulePageDomain.State(
                    stageStates: stages.map {
                        StageDomain.State(
                            stage: $0,
                            cards: (cardsPerDay[selectedDate]?[$0.id] ?? []).asIdentifiedArray(unchecked: true)
                        )
                    }.asIdentifiedArray(unchecked: true)
                )
            }
            
            set {
                self.stages = newValue.stageStates
                    .map { $0.stage }
                    .asIdentifiedArray(unchecked: true)
                
                self.cardsPerDay.updateValue(
                    newValue.stageStates.reduce(into: [:]) { initialResult, stageState in
                        initialResult.updateValue(stageState.cards, forKey: stageState.id)
                    },
                    forKey: selectedDate
                )
            }
        }
        
        init(schedule: Models.Schedule, stages: Stages, event: Event, selectedDate: CalendarDate) {
            print("Selected:", selectedDate, "Event Days:", event.festivalDates)
            
            self.selectedDate = selectedDate
            self.stages = stages
            self.event = event // For view injection, remove later.

            
            // Convert the raw data passed in to the correct state structure.
            // TODO: Refactor this so it's actually readable.
            self.cardsPerDay = event.festivalDates.reduce(into: [:]) { partialResult, day in
                partialResult[day] = stages.reduce(into: [:]) { partialResult, stage in
                    partialResult.updateValue(
                        schedule[page: .init(date: day, stageID: stage.id)].map {
                            ScheduleCardDomain.State(scheduleItem: $0, isSelected: false)
                        }.asIdentifiedArray(unchecked: true),
                        forKey: stage.id
                    )
                }
            }
        }

    }
    
    public enum Action: Equatable, BindableAction {
        
        case didTapUpdateDates
        
        case page(SchedulePageDomain.Action)
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .binding(\.$selectedDate):
                print("Selected Date \(state.selectedDate)")
                
                return .none
                
            case .didTapUpdateDates:
                return .none
                
            case .binding, .page:
                return .none
            }
        }
       
        Scope(state: \.schedulePageState, action: /Action.page) {
            SchedulePageDomain()
        }
    }
}

public struct SchedulePageDomain: Reducer {
    public struct State: Equatable {
        var stageStates: IdentifiedArrayOf<StageDomain.State>
    }
    
    public enum Action: Equatable {
        case didReorderStages(IdentifiedArrayOf<StageDomain.State>)
        case stage(id: StageDomain.State.ID, action: StageDomain.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            
            switch action {
            case .stage:
                return .none
            case let .didReorderStages(newOrder):
                
                state.stageStates = newOrder
                return .none
            }
        }
        .forEach(\.stageStates, action: /Action.stage) {
            StageDomain()
        }
    }
}
import OSLog


public struct StageDomain: Reducer {
    public struct State: Identifiable, Equatable {
        public var id: Stage.ID { stage.id }
        var stage: Stage
        
        var cards: IdentifiedArrayOf<ScheduleCardDomain.State>
        
        init(stage: Stage, cards: IdentifiedArrayOf<ScheduleCardDomain.State>) {
            self.stage = stage
            self.cards = cards
        }
        
    }
    
    public enum Action: Equatable {
        case didReorderStages
        
        case card(id: ScheduleCardDomain.State.ID, action: ScheduleCardDomain.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            return .none
        }
        .forEach(\.cards, action: /Action.card) {
            ScheduleCardDomain()
        }
    }
}
