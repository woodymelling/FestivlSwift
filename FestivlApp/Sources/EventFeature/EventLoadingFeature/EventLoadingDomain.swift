//
// EventLoadingDomain.swift
//
//
//  Created by Woody on 4/23/2022.
//

import ComposableArchitecture
import Models
import Services

public extension Store where State == EventLoadingState, Action == EventLoadingAction {

    static func live(eventID: EventID, testMode: Bool = false) -> Store<EventLoadingState, EventLoadingAction> {
        .init(
            initialState: .init(eventID: eventID, isTestMode: testMode),
            reducer: eventLoadingReducer,
            environment: .init()
        )
    }
}

public struct EventLoadingState: Equatable {

    var eventID: EventID
    var isTestMode: Bool
    var eventState: EventState?

    public init(eventID: EventID, isTestMode: Bool) {
        self.eventID = eventID
        self.isTestMode = isTestMode
    }
}

public enum EventLoadingAction {
    case onAppear
    case eventPublisherUpdate(Event)
    case eventAction(EventAction)
}

public struct EventLoadingEnvironment {
    public init(eventService: @escaping () -> EventListServiceProtocol = { EventListService.shared }) {
        self.eventService = eventService
    }

    public var eventService: () -> EventListServiceProtocol = { EventListService.shared }
}

public let eventLoadingReducer = Reducer<EventLoadingState, EventLoadingAction, EventLoadingEnvironment>.combine(

    eventReducer.optional().pullback(
        state: \.eventState,
        action: /EventLoadingAction.eventAction,
        environment: { _ in .init()}
    ),

    Reducer { state, action, environment in
        switch action {
        case .onAppear:
            return environment
                .eventService()
                .observeEvent(eventID: state.eventID)
                .eraseErrorToPrint(errorSource: "EventService")
                .map {
                    .eventPublisherUpdate($0)
                }
                .eraseToEffect()

        case .eventPublisherUpdate(let event):
            var eventState = state.eventState ?? .init(event: event, isTestMode: state.isTestMode)
            eventState.event = event
            state.eventState = eventState
            return .none
        case .eventAction:
            return .none
        }
    })
