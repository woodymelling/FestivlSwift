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

public struct TabBarView: View {

    let store: Store<EventState, TabBarAction>

    public init(store: Store<EventState, TabBarAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(\.$selectedTab)) {

                ScheduleView(store: store.scope(state: \.scheduleState, action: TabBarAction.scheduleAction))
                    .tabItem {
                        Label("Schedule", systemImage: "calendar")
                    }
                    .tag(Tab.schedule)

                ArtistListView(store: store.scope(state: \.artistListState, action: TabBarAction.artistListAction))
                    .tabItem {
                        Label("Artists", systemImage: "person.3")
                    }
                    .tag(Tab.artists)

                ExploreView(store: store.scope(state: \.exploreState, action: TabBarAction.exploreAction))
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
//
//struct TabBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabBarView(
//            store: .init(
//                initialState: .init(
//                    event: .testData,
//                    artists: Artist.testValues.asIdentifedArray,
//                    stages: Stage.testValues.asIdentifedArray,
//                    artistSets: ArtistSet.testValues().asIdentifedArray,
//                    selectedTab: .schedule,
//                    artistsListSearchText: "",
//                    scheduleSelectedStage: Stage.testValues[0],
//                    scheduleZoomAmount: 1,
//                    scheduleSelectedDate: Event.testData.startDate,
//                    scheduleScrollAmount: .zero
//                ),
//                reducer: tabBarReducer,
//                environment: TabBarEnvironment()
//            )
//        )
//    }
//}
