//
//  Explore.swift
//
//
//  Created by Woody on 3/2/2022.
//

import ComposableArchitecture
import Models
import ArtistPageFeature

public struct ExploreState: Equatable {
    public init(
        artists: IdentifiedArrayOf<Artist>,
        event: Event,
        stages: IdentifiedArrayOf<Stage>,
        schedule: Schedule,
        selectedArtistPageState: ArtistPageState?,
        favoriteArtists: Set<ArtistID>
    ) {
        self.event = event
        self.stages = stages
        self.schedule = schedule
        self.favoriteArtists = favoriteArtists

        self.artistStates = ArtistPageState.fromArtistList(
            artists,
            schedule: schedule,
            event: event,
            stages: stages,
            favoriteArtists: favoriteArtists
        )

        // If selectedArtistPageState has arrived, it may have a different state than the real state
        // for that artist, which is actually in the artists list. This can happen when favoriting.
        // I'm not sure if there's a better way to do this
        if let selectedArtistPageState = selectedArtistPageState {
            self.selectedArtistPageState = artistStates[id: selectedArtistPageState.artist.id!]
        }
        
    }

    public var artistStates: IdentifiedArrayOf<ArtistPageState>
    public let event: Event
    public let stages: IdentifiedArrayOf<Stage>
    public let schedule: Schedule
    public var favoriteArtists: Set<ArtistID>

    @BindableState public var selectedArtistPageState: ArtistPageState?

}

public enum ExploreAction: BindableAction {
    case binding(_ action: BindingAction<ExploreState>)
    case didSelectArtist(Artist)
    case artistPage(id: String?, action: ArtistPageAction)
}

public struct ExploreEnvironment {
    public init() {}
}

public let exploreReducer = Reducer<ExploreState, ExploreAction, ExploreEnvironment>.combine (

//    artistPageReducer.optional().pullback(state: \.selectedArtistPageState, action: /ExploreAction.artistPage, environment: { _ in .init() }),
    artistPageReducer.forEach(state: \.artistStates, action: /ExploreAction.artistPage, environment:   { _ in .init() }),

    Reducer { state, action, _ in
        switch action {
        case .binding:
            return .none
        case .didSelectArtist(let artist):
            state.selectedArtistPageState = .init(
                artist: artist,
                event: state.event,
                setsForArtist: state.schedule.scheduleItemsForArtist(artist: artist),
                stages: state.stages,
                isFavorite: state.favoriteArtists.contains(artist.id!)
            )

            return .none

        case .artistPage(id: let id, action: .favoriteArtistButtonTapped):
            state.favoriteArtists.toggle(item: id!)

            return .none
        case .artistPage:
            return .none
        }
    }
        .binding()
//        .debug()

)

extension Set {
    mutating func toggle(item: Element) {
        if contains(item) {
            remove(item)
        } else {
            insert(item)
        }
    }
}
