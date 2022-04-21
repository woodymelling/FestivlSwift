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
    public init(artists: IdentifiedArrayOf<Artist>, event: Event, stages: IdentifiedArrayOf<Stage>, schedule: Schedule, selectedArtistPageState: ArtistPageState?) {
        self.artists = artists
        self.event = event
        self.stages = stages
        self.schedule = schedule
        self.selectedArtistPageState = selectedArtistPageState
    }

    public let artists: IdentifiedArrayOf<Artist>
    public let event: Event
    public let stages: IdentifiedArrayOf<Stage>
    public let schedule: Schedule

    @BindableState public var selectedArtistPageState: ArtistPageState?

}

public enum ExploreAction: BindableAction {
    case binding(_ action: BindingAction<ExploreState>)
    case didSelectArtist(Artist)
    case artistPage(id: String?, ArtistPageAction)
}

public struct ExploreEnvironment {
    public init() {}
}

public let exploreReducer = Reducer<ExploreState, ExploreAction, ExploreEnvironment> { state, action, _ in
    switch action {
    case .binding:
        return .none
    case .didSelectArtist(let artist):
        state.selectedArtistPageState = .init(
            artist: artist,
            event: state.event,
            setsForArtist: state.schedule.scheduleItemsForArtist(artist: artist),
            stages: state.stages
        )

        return .none
    case .artistPage:
        return .none
    }
}
    .binding()
    .debug()
