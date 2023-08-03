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
        public init(destination: Destination.State? = nil) {
            self.destination = destination
        }
        
        @PresentationState var destination: Destination.State?
    }
    
    public struct Destination: Reducer {
        public enum State: Equatable {
            case signIn(SignInDomain.State)
            case signUp(SignUpDomain.State)
        }
        
        public enum Action: Equatable {
            case signIn(SignInDomain.Action)
            case signUp(SignUpDomain.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: /State.signIn, action: /Action.signIn) {
                SignInDomain()
            }
            
            Scope(state: /State.signUp, action: /Action.signUp) {
                SignUpDomain()
            }
        }
    }
    
    public enum Action: Equatable {
        case didTapSignInButton
        case didTapSignUpButton
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
                
            case .didTapSignInButton:
                state.destination = .signIn(SignInDomain.State())
                
                return .none
                
            case .didTapSignUpButton:
                state.destination = .signUp(SignUpDomain.State())
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}
