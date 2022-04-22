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

    public var isFavorite: Bool


    public init(artist: Artist, event: Event, setsForArtist: IdentifiedArrayOf<ScheduleItem>, stages: IdentifiedArrayOf<Stage>, isFavorite: Bool) {
        self.artist = artist
        self.event = event
        self.sets = setsForArtist
        self.stages = stages
        self.isFavorite = isFavorite
    }
}

public extension ArtistPageState {
    static func fromArtistList(
        _ artists: IdentifiedArrayOf<Artist>,
        schedule: Schedule,
        event: Event,
        stages: IdentifiedArrayOf<Stage>,
        favoriteArtists: Set<ArtistID>

    ) -> IdentifiedArrayOf<ArtistPageState> {
        // Set the artistStates and their sets in two passes so that it's O(A + S) instead of O(A*S)
        var artistStates = IdentifiedArray(uniqueElements: artists.map { artist in
            ArtistPageState(
                artist: artist,
                event: event,
                setsForArtist: .init(),
                stages: stages,
                isFavorite: favoriteArtists.contains(artist.id!)
            )
        })

        for scheduleItem in schedule.values.joined() {
            switch scheduleItem.type {
            case .artistSet(let artistID):
                artistStates[id: artistID]?.sets.append(scheduleItem)

            case .groupSet(let artistIDs):
                artistIDs.forEach {
                    artistStates[id: $0]?.sets.append(scheduleItem)
                }
            }
        }

        return artistStates
    }
}

extension ArtistPageState: Searchable {
    public var searchTerms: [String] {
        return [artist.name]
    }
}

public enum ArtistPageAction {
    case didTapArtistSet(ScheduleItem)
    case favoriteArtistButtonTapped
}

public struct ArtistPageEnvironment {
    public init() {}
}

public let artistPageReducer = Reducer<ArtistPageState, ArtistPageAction, ArtistPageEnvironment> { state, action, _ in
    switch action {
    case .didTapArtistSet:
        return .none
    case .favoriteArtistButtonTapped:
        state.isFavorite.toggle()
        return .none

    }
}

