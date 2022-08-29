//
//  EventList.swift
//
//
//  Created by Woody on 2/10/2022.
//

import SwiftUI
import ComposableArchitecture
import Services
import Models
import Utilities

extension Event: Searchable {
    public var searchTerms: [String] {
        return [name]
    }
}


public struct EventListView: View {
    let store: Store<EventListState, EventListAction>

    public init(store: Store<EventListState, EventListAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Group {
                    if viewStore.events.isEmpty {
                        ProgressView()
                    } else {
                        List {
                            ForEach(viewStore.events.filter { viewStore.isTestMode || !($0.isTestEvent ?? false)}.filterForSearchTerm(viewStore.searchText)) { event in
                                
                                Button(action: { viewStore.send(.selectedEvent(event))

                                }, label: {
                                    EventRowView(event: event)
                                })
                            }
                        }
                        .listStyle(.plain)
                        .searchable(text: viewStore.binding(\.$searchText))
                    }
                }
                .navigationTitle("Events")
            }
            #if os(iOS)
            .navigationViewStyle(.stack)
            #endif
            .onAppear {
                viewStore.send(.subscribeToEvents)
            }
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            EventListView(
                store: .init(
                    initialState: .init(isTestMode: true),
                    reducer: eventListReducer,
                    environment: .init(
                        eventListService: {
                            EventListMockService()
                        }
                    )
                )
            )
            .preferredColorScheme($0)
        }
    }
}
