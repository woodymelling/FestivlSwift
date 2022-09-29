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

public struct AppFeature: ReducerProtocol {
    
    public init() {}
    
    public struct State: Equatable {
        var eventState: EventLoading.State?
        var isTestMode: Bool
        
        @Storage(key: "savedEventID", defaultValue: "") var savedEventID: String

        public var eventListState: EventList.State

        public init(eventListState: EventList.State? = nil, isTestMode: Bool) {
            self.eventListState = eventListState ?? .init(isTestMode: isTestMode)
            self.isTestMode = isTestMode
            if !savedEventID.isEmpty {
                eventState = .init(eventID: savedEventID, isTestMode: isTestMode, isEventSpecificApplication: false)
            }
        }
    }

    public enum Action {
        case eventListAction(EventList.Action)
        case eventAction(EventLoading.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .eventListAction(.selectedEvent(let event)):
                state.savedEventID = event.id!
                state.eventState = .init(eventID: event.id!, isTestMode: state.isTestMode, isEventSpecificApplication: false)

                return .none
            case .eventListAction:
                return .none
                
            case .eventAction(.eventAction(.tabBarAction(.moreAction(.didExitEvent)))):
                state.eventState = nil
                state.savedEventID = ""
                return .none
                
            case .eventAction:
                return .none
            }
        }
        .ifLet(\.eventState, action: /Action.eventAction) {
            EventLoading()
        }
        
        Scope(state: \.eventListState, action: /Action.eventListAction) {
            EventList()
        }
    }
}


