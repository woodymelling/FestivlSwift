//
//  HomePageDomain.swift
//  
//
//  Created by Woodrow Melling on 7/27/23.
//

import Foundation
import ComposableArchitecture
import Models

public struct StartPageDomain: Reducer {
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

        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didSignUp(User.ID)
            case didSignIn(User.ID)
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case let .signIn(.successfullySignedIn(userID)):
                return .send(.delegate(.didSignIn(userID)))

            case let .signUp(.succesfullyCreatedAccount(userID)):
                return .send(.delegate(.didSignUp(userID)))

            case .delegate, .binding, .signIn, .signUp:
                return .none
            }
        }

        Scope(state: \.signInState, action: /Action.signIn) {
            SignInDomain()
        }
        
        Scope(state: \.signUpState, action: /Action.signUp) {
            SignUpDomain()
        }
    }
}

