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
    public var artistSets: IdentifiedArrayOf<ArtistSet>
    public var stages: IdentifiedArrayOf<Stage>
    
    @BindableState public var searchText: String = ""

    public init(
        event: Event,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        artistSets: IdentifiedArrayOf<ArtistSet>,
        searchText: String
    ) {
        self.event = event
        self.stages = stages
        self.artistSets = artistSets
        self.searchText = searchText

        self.artistStates = IdentifiedArray(uniqueElements: artists.map { artist in
            ArtistPageState(
                artist: artist,
                event: event,
                sets: artistSets.filter { $0.artistID == artist.id },
                stages: stages
            )
        })
    }
}

public enum ArtistListAction: BindableAction {
    case binding(_ action: BindingAction<ArtistListState>)
    case artistDetail(id: Artist.ID, action: ArtistPageAction)
}

public struct ArtistListEnvironment {
    public init() {}
}

public let artistListReducer = Reducer<ArtistListState, ArtistListAction, ArtistListEnvironment> { state, action, environment in
    switch action {
    case .binding:
        return .none
    case .artistDetail:
        return .none
    }
}
.binding()
