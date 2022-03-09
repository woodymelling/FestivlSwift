//
//  Event.swift
//
//
//  Created by Woody on 2/13/2022.
//

import SwiftUI
import ComposableArchitecture
import TabBarFeature

public struct EventView: View {
    let store: Store<EventState, EventAction>

    public init(store: Store<EventState, EventAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            IfLetStore(
                store.scope(
                    state: \EventState.tabBarState,
                    action: EventAction.tabBarAction
                ),
                then: TabBarView.init(store:),
                else: {
                    ProgressView()
                }
            )
            .onAppear { viewStore.send(.subscribeToDataPublishers) }
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            EventView(
                store: .init(
                    initialState: .init(event: .testData),
                    reducer: eventReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
