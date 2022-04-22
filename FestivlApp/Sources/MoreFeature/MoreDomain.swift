//
// MoreDomain.swift
//
//
//  Created by Woody on 4/22/2022.
//

import ComposableArchitecture
import Models

public struct MoreState: Equatable {

    let event: Event
    public init(event: Event) {
        self.event = event
    }
}

public enum MoreAction {

}

public struct MoreEnvironment {
    public init() {}
}

public let moreReducer = Reducer<MoreState, MoreAction, MoreEnvironment> { state, action, _ in
    return .none
}
