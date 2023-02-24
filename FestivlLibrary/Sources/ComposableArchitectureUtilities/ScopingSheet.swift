//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/9/22.
//

import Foundation
import SwiftUI
import ComposableArchitecture

public extension View {
    func sheet<State, LocalState, Action, LocalAction, IfContent> (
        scoping store: Store<State, Action>,
        state keyPath: WritableKeyPath<State, BindingState<LocalState?>>,
        action fromLocalAction: @escaping (LocalAction) -> Action,
        then thenView: @escaping (Store<LocalState, LocalAction>) -> IfContent
    ) -> some View
    where State: Equatable, Action: BindableAction, Action.State == State, LocalState: Identifiable & Equatable, IfContent: View
    {
        WithViewStore(store) { viewStore in
            self.sheet(item: viewStore.binding(keyPath)) { _ in
                IfLetStore(
                    store.scope(
                        state: { $0[keyPath: keyPath].wrappedValue },
                        action: fromLocalAction
                    ),
                    then: thenView
                )
            }
        }
    }
}
