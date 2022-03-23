//
// ManagerEventListDomain.swift
//
//
//  Created by Woody on 3/8/2022.
//

import ComposableArchitecture
import Models
import Services

public struct ManagerEventListState: Equatable {
    var events: IdentifiedArrayOf<Event>
    var loadingEvents: Bool {
        events.isEmpty
    }
    public init(events: IdentifiedArrayOf<Event> = []) {
        self.events = events
    }
}

public enum ManagerEventListAction {
    case subscribeToDataPublishers
    case eventsPublisherUpdate(IdentifiedArrayOf<Event>)
    case didSelectEvent(Event)
}

public struct ManagerEventListEnvironment {
    public var eventListService: () -> EventListServiceProtocol
    public init(
        eventListService: @escaping () -> EventListServiceProtocol = { EventListService.shared }
    ) {
        self.eventListService = eventListService
    }

}

public let managerEventListReducer = Reducer<ManagerEventListState, ManagerEventListAction, ManagerEventListEnvironment> { state, action, environment in
    switch action {
    case .subscribeToDataPublishers:
        return environment.eventListService().observeAllEvents().eraseErrorToPrint(errorSource: "EventsListPublisher")
            .map {
                ManagerEventListAction.eventsPublisherUpdate($0)
            }
            .eraseToEffect()

    case .eventsPublisherUpdate(let events):
        state.events = events
        return .none
    case .didSelectEvent:
        return .none
    }
}
