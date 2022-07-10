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

    static func live(eventID: EventID, testMode: Bool = false, isEventSpecificApplication: Bool) -> Store<EventLoadingState, EventLoadingAction> {
        .init(
            initialState: .init(eventID: eventID, isTestMode: testMode, isEventSpecificApplication: isEventSpecificApplication),
            reducer: eventLoadingReducer,
            environment: .init()
        )
    }
}

public struct EventLoadingState: Equatable {

    var eventID: EventID
    let isTestMode: Bool
    let isEventSpecificApplication: Bool
    var eventState: EventState?

    public init(eventID: EventID, isTestMode: Bool, isEventSpecificApplication: Bool) {
        self.eventID = eventID
        self.isTestMode = isTestMode
        self.isEventSpecificApplication = isEventSpecificApplication
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
            var eventState = state.eventState ?? .init(
                event: event,
                isTestMode: state.isTestMode,
                isEventSpecificApplication: state.isEventSpecificApplication
            )
            eventState.event = event
            state.eventState = eventState
            return .none
        case .eventAction:
            return .none
        }
    })
