//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/9/22.
//

import SwiftUI
import ComposableArchitecture
import ArtistListFeature
import Models

public struct TabBarView: View {

    let store: Store<TabBarState, TabBarAction>

    public init(store: Store<TabBarState, TabBarAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(\.$selectedTab)) {
                Text("Schedule")
                    .tabItem {
                        Label("Schedule", systemImage: "calendar")
                    }
                    .tag(Tab.schedule)

                ArtistListView(
                    store: store.scope(
                        state: \.artistListState,
                        action: TabBarAction.artistListAction
                    )
                )
                    .tabItem {
                        Label("Artists", systemImage: "person.3")
                    }
                    .tag(Tab.artists)

                Text("Explore")
                    .tabItem {
                        // TODO: Get better icon
                        Label("Explore", systemImage: "barometer")
                    }
                    .tag(Tab.explore)

                Text("Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(Tab.settings)
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(
            store: .init(
                initialState: .init(
                    event: .testData,
                    artists: IdentifiedArrayOf(uniqueElements: Artist.testValues),
                    stages: IdentifiedArray(uniqueElements: [Stage.testData]),
                    artistSets: IdentifiedArray(uniqueElements: [ArtistSet.testData]),
                    artistListSearchText: ""
                ),
                reducer: tabBarReducer,
                environment: TabBarEnvironment()
            )
        )
    }
}
