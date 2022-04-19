//
//  Explore.swift
//
//
//  Created by Woody on 3/2/2022.
//

import ComposableArchitecture
import Models

public struct ExploreState: Equatable {
    public init(artists: IdentifiedArrayOf<Artist>, stages: IdentifiedArrayOf<Stage>, schedule: Schedule) {
        self.artists = artists
        self.stages = stages
        self.schedule = schedule
    }

    public let artists: IdentifiedArrayOf<Artist>
    public let stages: IdentifiedArrayOf<Stage>
    public let schedule: Schedule

}

public enum ExploreAction {

}

public struct ExploreEnvironment {
    public init() {}
}

public let exploreReducer = Reducer<ExploreState, ExploreAction, ExploreEnvironment> { state, action, _ in
    return .none
}
