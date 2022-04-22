//
// GroupSetDetailDomain.swift
//
//
//  Created by Woody on 4/16/2022.
//

import ComposableArchitecture
import Models
import ArtistPageFeature

public struct GroupSetDetailState: Equatable, Identifiable {
    public init(
        groupSet: ScheduleItem,
        event: Event,
        schedule: Schedule,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        favoriteArtists: Set<ArtistID>
    ) {
        self.event = event
        self.schedule = schedule
        self.groupSet = groupSet
        self.stages = stages

        if case let .groupSet(artistIDs) = groupSet.type {


            
            self.artistDetailStates = artistIDs
                .compactMap { artists[id: $0] }
                .map {
                    ArtistPageState(
                        artist: $0,
                        event: event,
                        setsForArtist: [],
                        stages: stages,
                        isFavorite: favoriteArtists.contains($0.id!)
                    )
                }
                .asIdentifedArray

            for scheduleItem in schedule.values.joined() {
                switch scheduleItem.type {
                case .artistSet(let artistID):
                    artistDetailStates[id: artistID]?.sets.append(scheduleItem)

                case .groupSet(let artistIDs):
                    artistIDs.forEach {
                        artistDetailStates[id: $0]?.sets.append(scheduleItem)
                    }
                }
            }
        } else {
            artistDetailStates = []
        }


    }

    public let event: Event
    public let schedule: Schedule
    public let groupSet: ScheduleItem

    public let stages: IdentifiedArrayOf<Stage>

    public var id: String? {
        groupSet.id
    }

    public var artistDetailStates: IdentifiedArrayOf<ArtistPageState>
}

public enum GroupSetDetailAction {
    case didTapScheduleItem(ScheduleItem)

    case artistDetailAction(id: String?, ArtistPageAction)
}

public struct GroupSetDetailEnvironment {
    public init() {}
}

public let groupSetDetailReducer = Reducer<GroupSetDetailState, GroupSetDetailAction, GroupSetDetailEnvironment> { state, action, _ in
    switch action {
    case .didTapScheduleItem(_):
        return .none
    case .artistDetailAction(id: _, .didTapArtistSet(let item)):
        return Effect(value: .didTapScheduleItem(item))

    case .artistDetailAction(id: let id, .favoriteArtistButtonTapped):
        state.artistDetailStates[id: id]?.isFavorite.toggle()
        return .none
    case .artistDetailAction:
        return .none
    }

}
    .debug()