//
//  SignInDomain.swift
//  
//
//  Created by Woodrow Melling on 7/29/23.
//

import Foundation
import ComposableArchitecture
import ComposableArchitectureForms
import FestivlDependencies

public struct SignInDomain: Reducer {
    public struct State: Equatable, HasFormState {
        @BindingState var email: String = ""
        @BindingState var password: String = ""
        
        public var formState: FormState<Field> = .init()
        var submitError: String?
        
        var isSigningIn = false
    }
    
    public enum Action: Equatable, BindableAction, HasFormAction {
        case binding(BindingAction<State>)
        case form(FormAction<State, Field>)
        
        case successfullySignedIn
        case failedToSignIn(FestivlError.SignInError?)
        
    }
    
    public enum Field: FormField {
        case email, password
        
        public var fieldDataLocation: PartialKeyPath<State> {
            switch self {
            case .email: \State.email
            case .password: \State.password
            }
        }
    }
    
    @Dependency(\.authenticationClient) var authenticationClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .form(.submittedForm):
                state.isSigningIn = true
                
                return .run { [password = state.password, email = state.email] send in
                    try await authenticationClient.signIn(SignInUpData(email: email, password: password))
                    
                    await send(.successfullySignedIn)
                    
                } catch: { error, send in
                    await send(.failedToSignIn(error as? FestivlError.SignInError))
                }
                
            case .successfullySignedIn:
                state.isSigningIn = false
                
                return .none
                
            case .failedToSignIn(let error):
                state.isSigningIn = false
                
                switch error {
                case .none, .operationNotAllowed, .other, .userDisabled:
                    state.submitError = error?.errorMessage
                case .invalidEmail:
                    state.formState.validationErrors[.email] = [error!.errorMessage]
                case .wrongPassword:
                    state.formState.validationErrors[.password] = [error!.errorMessage]
                }
                
                return .none
                
            case .binding, .form:
                return .none
            }
        }
        .form(\.formState) { _, _, _ in }
    }
}

extension FestivlError.SignInError {
    var errorMessage: String {
        switch self {
        case .operationNotAllowed, .other:
            "Failed to sign in."
        case .userDisabled:
            "Account disabled, please contact support."
        case .wrongPassword:
            "Incorrect password."
        case .invalidEmail:
            "Unrecognized email address."
        }
    }
}
