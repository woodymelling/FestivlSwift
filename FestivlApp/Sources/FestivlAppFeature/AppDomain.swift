//
//  App.swift
//
//
//  Created by Woody on 2/11/2022.
//

import ComposableArchitecture
import Models
import EventListFeature
import EventFeature
import Utilities
import FestivlDependencies

public struct AppFeature: ReducerProtocol {
    
    @Dependency(\.eventID) var eventID
    
    public init() {}
    
    public struct State: Equatable {
        var eventState: EventFeature.State?
        var eventListState: EventList.State = .init()
        
        public init() {}
    }

    public enum Action {
        case eventListAction(EventList.Action)
        case eventAction(EventFeature.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .eventListAction(.selectedEvent(let event)):
                eventID.value = event.id
                state.eventState = EventFeature.State()

                return .none
            case .eventListAction:
                return .none
                
            case .eventAction(.moreAction(.didExitEvent)):
                state.eventState = nil
//                state.savedEventID = ""
                return .none
                
            case .eventAction:
                return .none
            }
        }
        .ifLet(\.eventState, action: /Action.eventAction) {
            EventFeature()
        }
       
        Scope(state: \.eventListState, action: /Action.eventListAction) {
            EventList()
        }
    }
}


