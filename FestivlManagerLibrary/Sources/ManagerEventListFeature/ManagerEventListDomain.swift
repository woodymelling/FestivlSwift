//
// ManagerEventListDomain.swift
//
//
//  Created by Woody on 3/8/2022.
//

import ComposableArchitecture
import Models
import Services
import AddEditEventFeature

public struct ManagerEventListState: Equatable {
    var events: IdentifiedArrayOf<Event>
    var loadingEvents: Bool {
        events.isEmpty
    }

    @BindableState var addEventState: AddEditEventState?

    public init(events: IdentifiedArrayOf<Event> = [], addEventState: AddEditEventState?) {
        self.events = events
        self.addEventState = addEventState
    }
}

public enum ManagerEventListAction: BindableAction {
    case binding(_ action: BindingAction<ManagerEventListState>)
    case subscribeToDataPublishers
    case eventsPublisherUpdate(IdentifiedArrayOf<Event>)
    case didSelectEvent(Event)
    case didTapAddEventButton

    case addEventAction(AddEditEventAction)

}

public struct ManagerEventListEnvironment {
    public var eventListService: () -> EventListServiceProtocol
    public init(
        eventListService: @escaping () -> EventListServiceProtocol = { EventListService.shared }
    ) {
        self.eventListService = eventListService
    }

}

public let managerEventListReducer: Reducer<ManagerEventListState, ManagerEventListAction, ManagerEventListEnvironment> = .combine(
    addEditEventReducer.optional().pullback(
        state: \.addEventState,
        action: /ManagerEventListAction.addEventAction,
        environment:  { _ in .init() }
    ),


    Reducer { state, action, environment in
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
        case .didTapAddEventButton:
            state.addEventState = .init()

            return .none

        case .addEventAction(.closeModal(navigateTo: let event)):
            state.addEventState = nil
            if let event = event {
                return Effect(value: .didSelectEvent(event))
            } else {
                return .none
            }

        case .addEventAction:
            return .none
        case .binding(_):
            return .none
        }
    }
    .binding()
)

