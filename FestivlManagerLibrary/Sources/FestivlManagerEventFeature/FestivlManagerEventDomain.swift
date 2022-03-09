//
//  FestivlManagerEvent.swift
//
//
//  Created by Woody on 3/8/2022.
//

import ComposableArchitecture

public struct FestivlManagerEventState: Equatable {
    public init() {}
}

public enum FestivlManagerEventAction {

}

public struct FestivlManagerEventEnvironment {
    public init() {}
}

public let festivlManagerEventReducer = Reducer<FestivlManagerEventState, FestivlManagerEventAction, FestivlManagerEventEnvironment> { state, action, _ in
    return .none
}
