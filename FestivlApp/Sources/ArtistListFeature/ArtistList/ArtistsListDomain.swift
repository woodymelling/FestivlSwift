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

public struct ArtistListState: Equatable {

    public var event: Event
    public var artistStates: IdentifiedArrayOf<ArtistPageState>
    public var schedule: Schedule
    public var stages: IdentifiedArrayOf<Stage>
    
    @BindableState public var searchText: String = ""

    var filteredArtistStates: IdentifiedArrayOf<ArtistPageState> {
        artistStates.filterForSearchTerm(searchText)
    }

    public init(
        event: Event,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        schedule: Schedule,
        searchText: String,
        favoriteArtists: Set<ArtistID>
    ) {
        self.event = event
        self.stages = stages
        self.schedule = schedule
        self.searchText = searchText

        self.artistStates = ArtistPageState.fromArtistList(
            artists,
            schedule: schedule,
            event: event,
            stages: stages,
            favoriteArtists: favoriteArtists
        )
    }
}

public enum ArtistListAction: BindableAction {
    case binding(_ action: BindingAction<ArtistListState>)
    case artistDetail(id: Artist.ID, action: ArtistPageAction)
}

public struct ArtistListEnvironment {
    public init() {}
}

public let artistListReducer = Reducer<ArtistListState, ArtistListAction, ArtistListEnvironment>.combine(
    artistPageReducer.forEach(
        state: \ArtistListState.artistStates,
        action: /ArtistListAction.artistDetail,
        environment: { _ in .init() }
    ),

    Reducer<ArtistListState, ArtistListAction, ArtistListEnvironment> { state, action, environment in
        switch action {
        case .binding:
            return .none
        case .artistDetail:
            return .none
        }
    }
    .binding()
)


