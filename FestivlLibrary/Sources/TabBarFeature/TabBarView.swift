//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/9/22.
//

import SwiftUI
import ComposableArchitecture
import ArtistsFeature
import Models

enum Tab {
    case schedule, artists, explore, settings
}

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
                initialState: .init(event: .testData),
                reducer: tabBarReducer,
                environment: TabBarEnvironment()
            )
        )
    }
}

public struct TabBarState: Equatable {
    public init(event: Event, artistListState: ArtistListState = ArtistListState.init()) {
        self.event = event
        self.artistListState = artistListState
    }

    public var event: Event
    @BindableState var selectedTab: Tab = .schedule
    var artistListState = ArtistListState.init()
}

public enum TabBarAction: BindableAction {
    case binding(_ action: BindingAction<TabBarState>)
    case artistListAction(ArtistListAction)
}

public struct TabBarEnvironment {
    public init() { }
}

public let tabBarReducer = Reducer.combine(
    Reducer<TabBarState, TabBarAction, TabBarEnvironment> { state, action, _ in
        switch action {
        case .binding:
            return .none
        case .artistListAction:
            return .none
        }
    }
    .binding(),

    artistListReducer.pullback(
        state: \TabBarState.artistListState,
        action: /TabBarAction.artistListAction,
        environment: { (_: TabBarEnvironment) in ArtistListEnvironment() }
    )
)

