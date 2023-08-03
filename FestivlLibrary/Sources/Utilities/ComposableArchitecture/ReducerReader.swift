//
//  ReducerReader.swift
//  
//
//  Created by Woodrow Melling on 8/2/23.
//

import Foundation
import ComposableArchitecture


// A reducer that builds a reducer from the current state and action.
public struct ReducerReader<State, Action, Reader: Reducer>: Reducer
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

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    self.reader(state, action).reduce(into: &state, action: action)
  }
}
