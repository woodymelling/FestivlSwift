//
//  FestivlManagerEvent.swift
//
//
//  Created by Woody on 3/8/2022.
//

import SwiftUI
import ComposableArchitecture
import ManagerEventDashboardFeature

public struct FestivlManagerEventView: View {
    let store: Store<FestivlManagerEventState, FestivlManagerEventAction>

    public init(store: Store<FestivlManagerEventState, FestivlManagerEventAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                if viewStore.eventLoaded {
                    ManagerEventDashboardView(
                        store: store.scope(
                            state: \FestivlManagerEventState.dashboardState,
                            action: FestivlManagerEventAction.dashboardAction
                        )
                    )
                } else {
                    ProgressView()
                }
            }
            .onAppear {
                viewStore.send(.subscribeToDataPublishers)
            }

        }
    }
}

struct FestivlManagerEventView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            FestivlManagerEventView(
                store: .init(
                    initialState: .init(event: .testData),
                    reducer: festivlManagerEventReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
