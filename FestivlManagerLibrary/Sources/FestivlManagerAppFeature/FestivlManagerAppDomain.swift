//
//  FestivlManagerApp.swift
//
//
//  Created by Woody on 3/8/2022.
//

import ComposableArchitecture
import FestivlManagerEventFeature
import ManagerEventListFeature

public struct FestivlManagerAppState: Equatable {
    var eventState: FestivlManagerEventState?
    var eventListState: ManagerEventListState
    public init(eventState: FestivlManagerEventState? = nil, eventListState: ManagerEventListState) {
        self.eventState = eventState
        self.eventListState = eventListState
    }
}

public enum FestivlManagerAppAction {
    case eventAction(FestivlManagerEventAction)
    case eventListAction(ManagerEventListAction)
}

public struct FestivlManagerAppEnvironment {
    public init() {}
}

public let festivlManagerAppReducer = Reducer.combine(
    festivlManagerEventReducer.optional().pullback(
        state: \FestivlManagerAppState.eventState,
        action: /FestivlManagerAppAction.eventAction,
        environment: { (_: FestivlManagerAppEnvironment) in
            FestivlManagerEventEnvironment()
        }
    ),

    managerEventListReducer.pullback(
        state: \FestivlManagerAppState.eventListState,
        action: /FestivlManagerAppAction.eventListAction,
        environment: { _ in .init() }
    ),

    Reducer<FestivlManagerAppState, FestivlManagerAppAction, FestivlManagerAppEnvironment> { state, action, _ in
        switch action {
        case .eventListAction(.didSelectEvent(let event)):
            state.eventState = .init(event: event)
            return .none
        case .eventAction(.dashboardAction(.exitEvent)):
            state.eventState = nil
            return .none
        case .eventAction:
            return .none
        case .eventListAction:
            return .none
        }
    }
)
.debug()
