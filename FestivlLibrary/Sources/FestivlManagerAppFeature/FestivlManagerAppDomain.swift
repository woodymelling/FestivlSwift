//
//  FestivlManagerApp.swift
//
//
//  Created by Woody on 3/8/2022.
//

import ComposableArchitecture

public struct FestivlManagerAppState: Equatable {
    public init() {}
}

public enum FestivlManagerAppAction {

}

public struct FestivlManagerAppEnvironment {
    public init() {}
}

public let festivlManagerAppReducer = Reducer<FestivlManagerAppState, FestivlManagerAppAction, FestivlManagerAppEnvironment> { state, action, _ in
    return .none
}
