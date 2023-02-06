//
//  EventList.swift
//
//
//  Created by Woody on 2/10/2022.
//

import ComposableArchitecture
import Models
import Clients
import Combine

public struct EventList: ReducerProtocol {
    public init() {}
    
    @Dependency(\.eventClient.getEvents) var getEvents
    
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
        case eventUpdate(IdentifiedArrayOf<Event>)
        case task
        case selectedEvent(Event)
        
        case binding(_ action: BindingAction<State>)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .eventUpdate(let events):
                state.events = events
                return .none
                
            case .task:
                 
                return .run { send in
                    for try await events in getEvents() {
                        await send(.eventUpdate(events))
                    }
                    
                } catch: { error, _ in
                    print("Event List Publisher failure: \(error)")
                }

            case .binding:
                return .none
            case .selectedEvent:
                return .none
            }
        }
        
    }
}
