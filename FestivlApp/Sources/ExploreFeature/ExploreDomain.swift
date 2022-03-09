//
//  Explore.swift
//
//
//  Created by Woody on 3/2/2022.
//

import ComposableArchitecture
import Models

public struct ExploreState: Equatable {
    public init(artists: [Artist]) {
        self.artists = artists
    }

    let artists: [Artist]
}

public enum ExploreAction {

}

public struct ExploreEnvironment {
    public init() {}
}

public let exploreReducer = Reducer<ExploreState, ExploreAction, ExploreEnvironment> { state, action, _ in
    return .none
}
