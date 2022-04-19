//
//  ArtistPage.swift
//
//
//  Created by Woody on 2/13/2022.
//

import ComposableArchitecture
import Models
import IdentifiedCollections
import Utilities

public struct ArtistPageState: Equatable, Identifiable  {
    public var artist: Artist
    public var event: Event
    public var sets: IdentifiedArrayOf<ScheduleItem>
    public var stages: IdentifiedArrayOf<Stage>
    public var id: Artist.ID {
        return artist.id
    }


    public init(artist: Artist, event: Event, setsForArtist: IdentifiedArrayOf<ScheduleItem>, stages: IdentifiedArrayOf<Stage>) {
        self.artist = artist
        self.event = event
        self.sets = setsForArtist
        self.stages = stages
    }
}

extension ArtistPageState: Searchable {
    public var searchTerms: [String] {
        return [artist.name]
    }
}

public enum ArtistPageAction {
    case didTapArtistSet(ScheduleItem)
}

public struct ArtistPageEnvironment {
    public init() {}
}

public let artistPageReducer = Reducer<ArtistPageState, ArtistPageAction, ArtistPageEnvironment> { state, action, _ in
    switch action {
    case .didTapArtistSet:
        return .none
    }
}
