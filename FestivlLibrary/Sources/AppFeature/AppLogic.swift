//
//  App.swift
//
//
//  Created by Woody on 2/11/2022.
//

import ComposableArchitecture
import Models
import EventListFeature
import TabBarFeature

public struct AppState: Equatable {
    var selectedEvent: Event?
    var tabBarState: TabBarState? {
        get {
            guard let selectedEvent = selectedEvent else { return nil }

            return TabBarState(event: selectedEvent)
        }

        set {
            self.selectedEvent = newValue?.event
        }
    }

    public var eventListState: EventListState

    public init(
        selectedEvent: Event? = nil,
        eventListState: EventListState = .init()
    ) {
        self.selectedEvent = selectedEvent
        self.eventListState = eventListState
    }
}

public enum AppAction {
    case eventListAction(EventListAction)
    case tabBarAction(TabBarAction)
}

public struct AppEnvironment {
    public init() {}
}

public let appReducer = Reducer.combine (


    Reducer<AppState, AppAction, AppEnvironment> { state, action, _ in
        switch action {
        case .eventListAction(.selectedEvent(let event)):
            state.selectedEvent = event
            return .none
        case .eventListAction:
            return .none
        case .tabBarAction:
            return .none
        }
    },


    tabBarReducer.optional().pullback(
        state: \AppState.tabBarState,
        action: /AppAction.tabBarAction,
        environment: { (_: AppEnvironment) in
            TabBarEnvironment()
        }
    ),

    eventListReducer.pullback(
        state: \AppState.eventListState,
        action: /AppAction.eventListAction,
        environment: { _ in .init() }
    )

)
.debug()


