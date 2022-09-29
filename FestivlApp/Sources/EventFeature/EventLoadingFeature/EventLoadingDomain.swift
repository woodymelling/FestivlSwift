//
// EventLoadingDomain.swift
//
//
//  Created by Woody on 4/23/2022.
//

import ComposableArchitecture
import Models
import Services

public extension StoreOf<EventLoading> {

    static func live(eventID: EventID, testMode: Bool = false, isEventSpecificApplication: Bool) -> StoreOf<EventLoading> {
        .init(
            initialState: .init(eventID: eventID, isTestMode: testMode, isEventSpecificApplication: isEventSpecificApplication),
            reducer: EventLoading()
        )
    }
}

public struct EventLoading: ReducerProtocol {
    
    public init() {}
    
    var eventService: () -> EventListServiceProtocol = { EventListService.shared }
    
    public struct State: Equatable {

        var eventID: EventID
        let isTestMode: Bool
        let isEventSpecificApplication: Bool
        var eventState: EventFeature.State?

        public init(eventID: EventID, isTestMode: Bool, isEventSpecificApplication: Bool) {
            self.eventID = eventID
            self.isTestMode = isTestMode
            self.isEventSpecificApplication = isEventSpecificApplication
        }
    }

    public enum Action {
        case onAppear
        case eventPublisherUpdate(Event)
        case eventAction(EventFeature.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return eventService()
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
        }
        .ifLet(\.eventState, action: /Action.eventAction) {
            EventFeature()
        }
    }
}
