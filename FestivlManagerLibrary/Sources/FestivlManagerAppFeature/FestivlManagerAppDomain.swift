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
    Reducer<FestivlManagerAppState, FestivlManagerAppAction, FestivlManagerAppEnvironment> { state, action, _ in
        switch action {
        case .eventAction:
            return .none
        case .eventListAction:
            return .none
        }
    },
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
    )
)
.debug()
