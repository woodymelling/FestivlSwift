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

public struct EventList: ReducerProtocol {
    public init() {}
    
    var eventListService: () -> EventListServiceProtocol = { EventListService.shared }
    
    
    public struct State: Equatable {
        public var events: IdentifiedArrayOf<Event> = []
        @BindableState var searchText = ""
        public var isTestMode: Bool
        
        public init(events: IdentifiedArrayOf<Event> = [], isTestMode: Bool) {
            self.events = events
            self.isTestMode = isTestMode
        }
    }

    public enum Action: BindableAction {
        case firebaseUpdate(IdentifiedArrayOf<Event>)
        case subscribeToEvents
        case selectedEvent(Event)
        
        case binding(_ action: BindingAction<State>)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .firebaseUpdate(let events):
                state.events = events
                return .none
            case .subscribeToEvents:
                return eventListService()
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
        
    }
}
