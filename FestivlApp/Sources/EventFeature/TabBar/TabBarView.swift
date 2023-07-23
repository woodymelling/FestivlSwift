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
        @BindingViewState var selectedTab: Tab
        
        init(state: BindingViewStore<EventFeature.State>) {
            _selectedTab = state.$selectedTab
        }
    }

    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            TabView(selection: viewStore.$selectedTab) {
                NavigationView {
                    ScheduleLoadingView(store: store.scope(state: \.scheduleState, action: EventFeature.Action.scheduleAction))
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(Tab.schedule)

                NavigationView {
                    ArtistListView(store: store.scope(state: \.artistListState, action: EventFeature.Action.artistListAction))
                        
                }
                .navigationViewStyle(.stack)
                .tabItem { Label("Artists", systemImage: "person.3") }
                .tag(Tab.artists)
                
                
                NavigationView {
                    ExploreView(store: store.scope(state: \.exploreState, action: EventFeature.Action.exploreAction))
                }
                .navigationViewStyle(.stack)
                .tabItem { Label("Explore", systemImage: "barometer") }
                .tag(Tab.explore)
                
                NavigationView {
                    MoreView(store: store.scope(state: \.moreState, action: EventFeature.Action.moreAction))
                }
                .navigationViewStyle(.stack)
                .tabItem { Label("More", systemImage: "ellipsis") }
                .tag(Tab.more)
            }
        }
    }
}
