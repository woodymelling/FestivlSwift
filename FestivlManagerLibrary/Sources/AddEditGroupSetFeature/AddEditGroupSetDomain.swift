//
// AddEditGroupSetDomain.swift
//
//
//  Created by Woody on 4/10/2022.
//

import ComposableArchitecture

public struct AddEditGroupSetState: Equatable {
    public init() {}
}

public enum AddEditGroupSetAction {

}

public struct AddEditGroupSetEnvironment {
    public init() {}
}

public let addEditGroupSetReducer = Reducer<AddEditGroupSetState, AddEditGroupSetAction, AddEditGroupSetEnvironment> { state, action, _ in
    return .none
}