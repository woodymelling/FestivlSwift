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
import ScheduleFeature
import ExploreFeature
import MoreFeature


public enum Tab {
    case schedule, artists, explore, more
}

public struct TabBarView: View {

    let store: StoreOf<EventFeature>

    public init(store: StoreOf<EventFeature>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        var selectedTab: Tab
        
        init(state: EventFeature.State) {
            selectedTab = state.selectedTab
        }
    }

    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            TabView(
                selection: viewStore.binding(
                     get: \.selectedTab,
                     send: EventFeature.Action.didSelectTab
                )
            ) {
                ScheduleLoadingView(store: store.scope(state: \.scheduleState, action: EventFeature.Action.scheduleAction))
                    .tabItem {
                        Label("Schedule", systemImage: "calendar")
                    }
                    .tag(Tab.schedule)

                ArtistListView(store: store.scope(state: \.artistListState, action: EventFeature.Action.artistListAction))
                    .tabItem {
                        Label("Artists", systemImage: "person.3")
                    }
                    .tag(Tab.artists)
                
                ExploreView(store: store.scope(state: \.exploreState, action: EventFeature.Action.exploreAction))
                    .tabItem {
                        // TODO: Get better icon
                        Label("Explore", systemImage: "barometer")
                    }
                    .tag(Tab.explore)


                MoreView(store: store.scope(state: \.moreState, action: EventFeature.Action.moreAction))
                    .tabItem {
                        Label("More", systemImage: "ellipsis")
                    }
                    .tag(Tab.more)
            }
        }
    }
}
