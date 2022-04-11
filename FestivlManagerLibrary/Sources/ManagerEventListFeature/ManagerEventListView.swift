//
//  ManagerEventListView.swift
//
//
//  Created by Woody on 3/8/2022.
//

import SwiftUI
import ComposableArchitecture
import AddEditEventFeature

public struct ManagerEventListView: View {
    let store: Store<ManagerEventListState, ManagerEventListAction>

    public init(store: Store<ManagerEventListState, ManagerEventListAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Spacer()
                    Button(action: { viewStore.send(.didTapAddEventButton) }, label: {
                        Image(systemName: "plus")
                            .resizable()
                    })
                    .frame(square: 18)
                    .padding()
                    .buttonStyle(.borderless)
                }
                if viewStore.loadingEvents {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewStore.events) { event in
                            Button(action: {
                                viewStore.send(.didSelectEvent(event), animation: .linear)
                            }, label: {
                                EventListRow(event: event)
                            })
                            .buttonStyle(.plain)

                            Divider()
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .sheet(
                scoping: store,
                state: \ManagerEventListState.$addEventState,
                action: ManagerEventListAction.addEventAction,
                then: AddEditEventView.init
            )
            .onAppear {
                viewStore.send(.subscribeToDataPublishers)
            }

        }
    }
}

struct ManagerEventListView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ManagerEventListView(
                store: .init(
                    initialState: .init(addEventState: nil),
                    reducer: managerEventListReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
