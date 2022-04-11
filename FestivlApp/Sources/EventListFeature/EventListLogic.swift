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
    public var events: IdentifiedArrayOf<Event> = []
    @BindableState var searchText = ""
    
    public init(events: IdentifiedArrayOf<Event> = []) {
        self.events = events
    }
}

public enum EventListAction: BindableAction {
    case firebaseUpdate(IdentifiedArrayOf<Event>)
    case subscribeToEvents
    case selectedEvent(Event)
    
    case binding(_ action: BindingAction<EventListState>)
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
            .eraseErrorToPrint(errorSource: "EventListPublisher")
            .map {
                .firebaseUpdate($0)
            }
            .eraseToEffect()
    case .binding:
        return .none
    case .selectedEvent:
        return .none
    }
}
.binding()
