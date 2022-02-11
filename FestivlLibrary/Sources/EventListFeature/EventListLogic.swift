//
//  EventList.swift
//
//
//  Created by Woody on 2/10/2022.
//

import ComposableArchitecture
import Models
import Services
import Combine

public struct EventListState: Equatable {
    var events: [Event]
    public init(events: [Event] = []) {
        self.events = events
    }
}

public enum EventListAction {
    case firebaseUpdate([Event])
    case subscribeToEvents
}

public struct EventListEnvironment {
    public init(
        eventListService: @escaping () -> EventListServiceProtocol = { EventListService.shared }
    ) {
        self.eventListService = eventListService
    }

    public var eventListService: () -> EventListServiceProtocol = { EventListService.shared }

}

public let eventListReducer = Reducer<EventListState, EventListAction, EventListEnvironment> { state, action, environment in
    switch action {
    case .firebaseUpdate(let events):
        state.events = events
        return .none
    case .subscribeToEvents:
        return environment
            .eventListService()
            .observeAllEvents()
            .catch { _ in Empty<[Event], Never>() } // TODO: Error Handling
            .map {
                .firebaseUpdate($0)
            }
            .eraseToEffect()
    }
}
