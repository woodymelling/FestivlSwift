//
//  File.swift
//  
//
//  Created by Woody on 2/14/22.
//

import Foundation
import ComposableArchitecture
import Models
import ArtistListFeature


public enum Tab {
    case schedule, artists, explore, settings
}

public struct TabBarState: Equatable {
    public init(
        event: Event,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        artistSets: IdentifiedArrayOf<ArtistSet>,
        selectedTab: Tab = .schedule,
        artistListSearchText: String
    ) {
        self.event = event
        self.artists = artists
        self.stages = stages
        self.artistSets = artistSets
        self.selectedTab = selectedTab
        self.artistsListSearchText = artistListSearchText
    }

    public private(set) var event: Event
    public private(set) var artists: IdentifiedArrayOf<Artist>
    public private(set) var stages: IdentifiedArrayOf<Stage>
    public private(set) var artistSets: IdentifiedArrayOf<ArtistSet>

    @BindableState public var selectedTab: Tab = .schedule

    public var artistsListSearchText: String
    
    var artistListState: ArtistListState {
        get {
            .init(
                event: event,
                artists: artists,
                stages: stages,
                artistSets: artistSets,
                searchText: artistsListSearchText
            )
        }

        set {
            self.event = newValue.event
            self.artists = IdentifiedArray(uniqueElements: newValue.artistStates.map { $0.artist })
            self.artistsListSearchText = newValue.searchText
        }
    }
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
