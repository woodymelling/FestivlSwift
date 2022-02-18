//
//  ArtistPage.swift
//
//
//  Created by Woody on 2/13/2022.
//

import ComposableArchitecture
import Models
import IdentifiedCollections

public struct ArtistPageState: Equatable, Identifiable {
    public var artist: Artist
    public var event: Event
    public var sets: IdentifiedArrayOf<ArtistSet>
    public var stages: IdentifiedArrayOf<Stage>
    public var id: Artist.ID {
        return artist.id
    }


    public init(artist: Artist, event: Event, sets: IdentifiedArrayOf<ArtistSet>, stages: IdentifiedArrayOf<Stage>) {
        self.artist = artist
        self.event = event
        self.sets = sets
        self.stages = stages
    }
}

public enum ArtistPageAction {

}

public struct ArtistPageEnvironment {
    public init() {}
}

public let artistPageReducer = Reducer<ArtistPageState, ArtistPageAction, ArtistPageEnvironment> { state, action, _ in
    return .none
}
