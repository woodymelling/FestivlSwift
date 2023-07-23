//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/3/23.
//

import Foundation
import ComposableArchitecture
import FestivlDependencies
import Models
import Utilities

public struct ScheduleManagementDomain: Reducer {
    
    public init() {}
    
    public struct State: Equatable {
        public init() {}
        
        var artistListState: ScheduleArtistListDomain.State = .init()
        
        /// The state of the actual schedule grid portion
        var scheduleState: ScheduleDomain.State?
        
        var schedule: Schedule?
        var stages: Stages?
        var event: Event?
        
        @BindingState var presentingArtistList: Bool = false
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case task
        
        case didTapArtistListToggle
        
        case artistListAction(ScheduleArtistListDomain.Action)
        case scheduleAction(ScheduleDomain.Action)
        
        case dataUpdate(DataUpdate)
        
        public enum DataUpdate: Equatable {
            case schedule(Schedule)
            case stages(Stages)
            case event(Event)
        }
    }
    
    @Dependency(\.scheduleClient) var scheduleClient
    @Dependency(\.stageClient) var stageClient
    @Dependency(\.eventClient) var eventClient
    @Dependency(\.date) var date
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .task:
                // TODO: Potentially cancel future data ovservation for schedule and stages so local data doesn't get overriden when the schedule changes
                return .merge(
                    .observe(eventClient.getEvent(), sending: { .dataUpdate(.event($0))}),
                    .observe(scheduleClient.getSchedule(), sending: { .dataUpdate(.schedule($0)) }),
                    .observe(stageClient.getStages(), sending: { .dataUpdate(.stages($0)) })
                )
                
            case let .dataUpdate(dataType):
                switch dataType {
                case let .schedule(schedule): state.schedule = schedule
                case let .stages(stages): state.stages = stages
                case let .event(event): state.event = event
                }
                
                /// When all data for the scheduleState is loaded, create a scheduleState that has honest data
                if let schedule = state.schedule,
                   let stages = state.stages,
                   let event = state.event,
                   state.scheduleState == nil
                {
                    state.scheduleState = ScheduleDomain.State(
                        schedule: schedule,
                        stages: stages,
                        event: event,
                        selectedDate: event.dateForCalendarAtLaunch(selectedDate: state.scheduleState?.selectedDate)
                    )
                }
                
                return .none
                
            case .didTapArtistListToggle:
                state.presentingArtistList.toggle()
                return .none
                
            case .artistListAction, .scheduleAction:
                return .none
            }
        }
        .ifLet(\.scheduleState, action: /Action.scheduleAction) {
            ScheduleDomain()
                ._printChanges()
        }
        
        // Always keep sidebar lists running
        Scope(state: \.artistListState, action: /Action.artistListAction) {
            ScheduleArtistListDomain()
        }
    }
}
