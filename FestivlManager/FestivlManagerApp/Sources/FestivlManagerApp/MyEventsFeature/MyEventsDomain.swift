//
//  MyEventsDomain.swift
//  
//
//  Created by Woodrow Melling on 8/2/23.
//

import Foundation
import ComposableArchitecture
import FestivlDependencies


public struct LoggedInDomain: Reducer {
    public struct State: Equatable {
        
    }
    
    public enum Action {
        case didTapLogout
    }
    
    @Dependency(\.authenticationClient.signOut) var signOut
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .didTapLogout:
                return .run { _ in
                    try? await signOut() // TODO: ErrorHandling
                }
            }
        }
    }
}
