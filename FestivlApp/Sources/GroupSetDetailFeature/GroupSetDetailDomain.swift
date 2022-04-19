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
        stages: IdentifiedArrayOf<Stage>
    ) {
        self.event = event
        self.schedule = schedule
        self.groupSet = groupSet

        self.stages = stages

        if case let .groupSet(artistIDs) = groupSet.type {
            self.artistDetailStates = artistIDs
                .compactMap { artists[id: $0] }
                .map { ArtistPageState(
                    artist: $0,
                    event: event,
                    setsForArtist: schedule.scheduleItemsForArtist(artist: $0),
                    stages: stages)
                }
                .asIdentifedArray
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
    case .artistDetailAction:
        return .none
    }
}
