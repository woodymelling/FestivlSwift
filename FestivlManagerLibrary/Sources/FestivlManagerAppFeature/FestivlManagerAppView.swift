//
//  FestivlManagerApp.swift
//
//
//  Created by Woody on 3/8/2022.
//

import SwiftUI
import ComposableArchitecture
import ManagerEventListFeature
import FestivlManagerEventFeature

public struct FestivlManagerAppView: View {
    let store: Store<FestivlManagerAppState, FestivlManagerAppAction>

    public init(store: Store<FestivlManagerAppState, FestivlManagerAppAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            IfLetStore(
                store.scope(
                    state: \FestivlManagerAppState.eventState,
                    action: FestivlManagerAppAction.eventAction
                ),
                then: FestivlManagerEventView.init(store:),
                else: {
                    ManagerEventListView(
                        store: store.scope(
                            state: \FestivlManagerAppState.eventListState,
                            action: FestivlManagerAppAction.eventListAction
                        )
                    )
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct FestivlManagerAppView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            FestivlManagerAppView(
                store: .init(
                    initialState: .init(eventListState: .init(addEventState: nil)),
                    reducer: festivlManagerAppReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
