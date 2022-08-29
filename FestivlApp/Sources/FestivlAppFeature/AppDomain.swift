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

public struct AppState: Equatable {
    var eventState: EventLoadingState?
    var isTestMode: Bool
    
    @Storage(key: "savedEventID", defaultValue: "") var savedEventID: String

    public var eventListState: EventListState

    public init(
        eventListState: EventListState? = nil,
        isTestMode: Bool
    ) {
        self.eventListState = eventListState ?? .init(isTestMode: isTestMode)
        self.isTestMode = isTestMode
        if !savedEventID.isEmpty {
            eventState = .init(eventID: savedEventID, isTestMode: isTestMode, isEventSpecificApplication: false)
        }
    }
}

public enum AppAction {
    case eventListAction(EventListAction)
    case eventAction(EventLoadingAction)
}

public struct AppEnvironment {
    public init() {}
}

public let appReducer = Reducer.combine (

    Reducer<AppState, AppAction, AppEnvironment> { state, action, _ in
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
    },

    eventLoadingReducer.optional().pullback(
        state: \AppState.eventState,
        action: /AppAction.eventAction,
        environment: { (_: AppEnvironment) in
            EventLoadingEnvironment()
        }
    ),

    eventListReducer.pullback(
        state: \AppState.eventListState,
        action: /AppAction.eventListAction,
        environment: { _ in .init() }
    )

)
.debug()


