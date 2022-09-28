//
//  ArtistList.swift
//
//
//  Created by Woody on 2/9/2022.
//

import ComposableArchitecture
import Models
import Utilities
import Services
import Combine
import ArtistPageFeature

extension Artist: Searchable {
    public var searchTerms: [String] {
        [name]
    }
}

public struct ArtistListFeature: ReducerProtocol {
    public init() {}
    
    public struct State: Equatable {

        public var event: Event
        public var artistStates: IdentifiedArrayOf<ArtistPage.State>
        public var schedule: Schedule
        public var stages: IdentifiedArrayOf<Stage>
        var showArtistImages: Bool
        
        @BindableState public var searchText: String = ""

        var filteredArtistStates: IdentifiedArrayOf<ArtistPage.State> {
            artistStates.filterForSearchTerm(searchText)
        }

        public init(
            event: Event,
            artists: IdentifiedArrayOf<Artist>,
            stages: IdentifiedArrayOf<Stage>,
            schedule: Schedule,
            searchText: String,
            favoriteArtists: Set<ArtistID>,
            showArtistImages: Bool
        ) {
            self.event = event
            self.stages = stages
            self.schedule = schedule
            self.searchText = searchText
            self.showArtistImages = showArtistImages

            self.artistStates = ArtistPage.State.fromArtistList(
                artists,
                schedule: schedule,
                event: event,
                stages: stages,
                favoriteArtists: favoriteArtists
            )
        }
    }

    public enum Action: BindableAction {
        case binding(_ action: BindingAction<State>)
        case artistDetail(id: Artist.ID, action: ArtistPage.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding, .artistDetail:
                return .none
            }
        }
        .forEach(\.artistStates, action: /Action.artistDetail) {
            ArtistPage()
        }
    }
}
