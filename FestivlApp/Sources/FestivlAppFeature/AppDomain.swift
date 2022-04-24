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

public struct AppState: Equatable {
    var eventState: EventLoadingState?
    var isTestMode: Bool

    public var eventListState: EventListState

    public init(
        eventListState: EventListState = .init(),
        isTestMode: Bool
    ) {
        self.eventListState = eventListState
        self.isTestMode = isTestMode
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
            state.eventState = .init(eventID: event.id!, isTestMode: state.isTestMode)

            return .none
        case .eventListAction:
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


