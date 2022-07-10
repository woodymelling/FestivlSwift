//
//  EventLoadingView.swift
//
//
//  Created by Woody on 4/23/2022.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct EventLoadingView: View {
    let store: Store<EventLoadingState, EventLoadingAction>

    public init(store: Store<EventLoadingState, EventLoadingAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in

            IfLetStore(
                store.scope(
                    state: \.eventState,
                    action: EventLoadingAction.eventAction
                ),
                then: EventView.init(store:),
                else: {
                    ProgressView()
                }
            )
            .onAppear {
                viewStore.send(.onAppear)
            }

        }
    }
}

struct EventLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            EventLoadingView(
                store: .init(
                    initialState: .init(eventID: Event.testData.id!, isTestMode: true, isEventSpecificApplication: false),
                    reducer: eventLoadingReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
