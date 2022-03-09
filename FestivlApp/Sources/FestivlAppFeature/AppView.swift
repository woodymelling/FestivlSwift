//
//  App.swift
//
//
//  Created by Woody on 2/11/2022.
//

import SwiftUI
import ComposableArchitecture
import EventListFeature
import EventFeature

public struct AppView: View {
    let store: Store<AppState, AppAction>

    public init(store: Store<AppState, AppAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            IfLetStore(
                store.scope(
                    state: \AppState.eventState,
                    action: AppAction.eventAction
                ),
                then: EventView.init(store:),
                else: {
                    EventListView(
                        store: store.scope(
                            state: \AppState.eventListState,
                            action: AppAction.eventListAction
                        )
                    )
                }
            )
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            AppView(
                store: .init(
                    initialState: AppState(),
                    reducer: appReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
