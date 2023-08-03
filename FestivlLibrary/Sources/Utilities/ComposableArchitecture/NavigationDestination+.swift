//
//  NavigationDestination+.swift
//  
//
//  Created by Woodrow Melling on 7/27/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

// Does the same thing, but with `content` as the label, instead of `destination`,
// This means it can be used interchangebly with .sheet
extension View {
    @inlinable public func navigationDestination<
      State, Action, DestinationState, DestinationAction, Destination: View
    >(
      store: Store<PresentationState<State>, PresentationAction<Action>>,
      state toDestinationState: @escaping (_ state: State) -> DestinationState?,
      action fromDestinationAction: @escaping (_ destinationAction: DestinationAction) -> Action,
      @ViewBuilder content: @escaping (_ store: Store<DestinationState, DestinationAction>) ->
        Destination
    ) -> some View {
        self.navigationDestination(store: store, state: toDestinationState, action: fromDestinationAction, destination: content)
    }
}
