//
//  App.swift
//
//
//  Created by Woody on 2/11/2022.
//

import ComposableArchitecture
import Models
import EventListFeature
import EventFeature
import Utilities
import FestivlDependencies

public struct AppFeature: ReducerProtocol {
    
    @Dependency(\.eventID) var eventID
    
    public init() {}
    
    public struct State: Equatable {
        var eventState: EventFeature.State?
        var eventListState: EventList.State = .init()
        
        var selectedEventID: Event.ID?
        
        public init() {}
    }

    public enum Action {
        case eventListAction(EventList.Action)
        case eventAction(EventFeature.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        ReducerReader { state, action in
            
            Reduce { state, action in
                switch action {
                case .eventListAction(.selectedEvent(let event)):
                    state.eventState = EventFeature.State()
                    state.selectedEventID = event.id
                    
                    return .none
                case .eventListAction:
                    return .none
                    
                case .eventAction(.moreAction(.didExitEvent)):
                    state.eventState = nil
                    //                state.savedEventID = ""
                    return .none
                    
                case .eventAction:
                    return .none
                }
            }
            .ifLet(\.eventState, action: /Action.eventAction) {
                EventFeature()
                    .dependency(\.eventID, state.selectedEventID ?? "")
            }
            
            
        }
       
        Scope(state: \.eventListState, action: /Action.eventListAction) {
            EventList()
        }
    }
}


// A reducer that builds a reducer from the current state and action.
public struct ReducerReader<State, Action, Reader: ReducerProtocol>: ReducerProtocol
where Reader.State == State, Reader.Action == Action {
  let reader: (State, Action) -> Reader

  /// Initializes a reducer that builds a reducer from the current state and action.
  ///
  /// - Parameter reader: A reducer builder that has access to the current state and action.

  public init(@ReducerBuilder<State, Action> _ reader: @escaping (State, Action) -> Reader) {
    self.init(internal: reader)
  }

  private init(internal reader: @escaping (State, Action) -> Reader) {
    self.reader = reader
  }

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    self.reader(state, action).reduce(into: &state, action: action)
  }
}
