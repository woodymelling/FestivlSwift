//
//  HomePageDomain.swift
//  
//
//  Created by Woodrow Melling on 7/27/23.
//

import Foundation
import ComposableArchitecture

public struct HomePageDomain: Reducer {
    public init() {}
    
    public struct State: Equatable {
        public init() {}
        
        
        
        var signInState: SignInDomain.State = .init()
        var signUpState: SignUpDomain.State = .init()
        
        @BindingState var authFlow: AuthenticationFlow = .signUp
    }
    
    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        
        case signIn(SignInDomain.Action)
        case signUp(SignUpDomain.Action)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.signInState, action: /Action.signIn) {
            SignInDomain()
        }
        
        Scope(state: \.signUpState, action: /Action.signUp) {
            SignUpDomain()
        }
    }
}

