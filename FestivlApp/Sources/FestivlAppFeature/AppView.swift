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
    let store: StoreOf<AppFeature>


    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            IfLetStore(
                store.scope(
                    state: \AppFeature.State.eventState,
                    action: AppFeature.Action.eventAction
                ),
                then: EventLoadingView.init(store:),
                else: {
                    EventListView(
                        store: store.scope(
                            state: \AppFeature.State.eventListState,
                            action: AppFeature.Action.eventListAction
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
                store: .init(initialState: .init(isTestMode: true), reducer: AppFeature())
            )
            .preferredColorScheme($0)
        }
    }
}
