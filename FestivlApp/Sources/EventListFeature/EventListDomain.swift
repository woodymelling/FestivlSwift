//
//  EventList.swift
//
//
//  Created by Woody on 2/10/2022.
//

import ComposableArchitecture
import Models
import FestivlDependencies
import Combine

public struct EventList: Reducer {
    public init() {}
    
    @Dependency(\.eventClient.getPublicEvents) var getEvents
    
    public struct State: Equatable {
        public init() {}
        
        var events: IdentifiedArrayOf<Event> = []
        
        @BindingState var searchText = ""
        
        struct Thing: Equatable {
             var foo: Bool = false
        }
        
        @BindingState var thing: Thing = .init()

        var isLoading: Bool = true
        
        var currentEnvironment = {
            @Dependency(\.currentEnvironment) var currentEnvironment
            return currentEnvironment
        }()
        
        var eventsWithTestMode: IdentifiedArrayOf<Event> {
            switch currentEnvironment {
            case .live:
                return events.filter { !$0.isTestEvent }
            case .test:
                return events
            }
        }
    }

    public enum Action: BindableAction {
        case task
        case binding(_ action: BindingAction<State>)
        
        case eventUpdate(IdentifiedArrayOf<Event>)
        case selectedEvent(Event)
        
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .eventUpdate(let events):
                state.isLoading = false
                state.events = events
                
                return .none
                
            case .task:
                return .run { send in
                    for try await events in getEvents().values {
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


