//
//  File.swift
//  
//
//  Created by Woodrow Melling on 2/24/23.
//

import Foundation
import ComposableArchitecture
import Models
import FestivlDependencies
import Utilities

struct ManagerEventListDomain: Reducer {
    
    @Dependency(\.eventClient) var eventClient
    
    struct State {
        var events: IdentifiedArrayOf<Event> = []
        var isLoading: Bool = false
        
        var searchText: String = ""
    }
    
    enum Action {
        case task
        case searchTextDidChange(String)
        
        case didLoadEvents(IdentifiedArrayOf<Event>)
        
        case addEventButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .task:
                state.isLoading = true
//                
                return .run { send in
                    for try await events in eventClient.getEvents().values {
                        await send(.didLoadEvents(events))
                    }
                }
                
            case let .searchTextDidChange(newSearchText):
                state.searchText = newSearchText
                
            case let .didLoadEvents(events):
                state.isLoading = false
                state.events = events
                
            case .addEventButtonTapped:
                break
            }
            
            return .none
        }
    }
}

extension Event: Searchable {
    public var searchTerms: [String] {
        return [name]
    }
}
