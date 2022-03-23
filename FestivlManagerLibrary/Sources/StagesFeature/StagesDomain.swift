//
// StagesDomain.swift
//
//
//  Created by Woody on 3/22/2022.
//

import ComposableArchitecture
import Models

public struct StagesState: Equatable {
    public init() {}

    public var stages: [Stage]
}

public enum StagesAction {

}

public struct StagesEnvironment {
    public init() {}
}

public let stagesReducer = Reducer<StagesState, StagesAction, StagesEnvironment> { state, action, _ in
    return .none
}
