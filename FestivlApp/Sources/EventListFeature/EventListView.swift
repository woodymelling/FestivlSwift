//
//  EventList.swift
//
//
//  Created by Woody on 2/10/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import Utilities
import Components

extension Event: Searchable {
    public var searchTerms: [String] {
        return [name]
    }
}

public struct EventListView: View {
    let store: StoreOf<EventList>

    public init(store: StoreOf<EventList>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                SimpleSearchableList(
                    data: viewStore.eventsWithTestMode,
                    searchText: viewStore.binding(\.$searchText),
                    isLoading: viewStore.isLoading
                ) { event in
                    Button {
                        viewStore.send(.selectedEvent(event))
                    } label: {
                        EventRowView(event: event)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Events")
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView(
            store: .init(
                initialState: .init(),
                reducer: EventList()
            )
        )
    }
}
