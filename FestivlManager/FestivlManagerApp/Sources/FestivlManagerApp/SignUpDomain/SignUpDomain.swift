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
import SwiftUI

public struct SignUpDomain: Reducer {
    public struct State: Equatable, HasFormState {
        public init(
            formState: FormState<Field> = .init(),
            email: String = "",
            password: String = ""
        ) {
            self.formState = formState
            self.email = email
            self.password = password
        }
        
        public var formState: FormState<Field> = .init()
        var submitError: String?
        
        @BindingState var email: String = ""
        @BindingState var password: String = ""
        
        var isCreatingAccount: Bool = false
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
    
    public enum Action: BindableAction, HasFormAction, Equatable {
        case binding(BindingAction<State>)
        case form(FormAction<State, Field>)
                
        case succesfullyCreatedAccount
        case failedToCreateAccount(FestivlError.SignUpError?)
    }
    
    @Dependency(\.authenticationClient) var authenticationClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .form(.submittedForm):
                state.isCreatingAccount = true
                
                return .run { [password = state.password, email = state.email] send in
                    try await authenticationClient.signUp(SignInUpData(email: email, password: password))
                    
                    await send(.succesfullyCreatedAccount)
                    
                } catch: { error, send in
                    await send(.failedToCreateAccount(error as? FestivlError.SignUpError))
                }

            case .succesfullyCreatedAccount:
                state.isCreatingAccount = false
                return .none
                
            case .failedToCreateAccount(let error):
                state.isCreatingAccount = false
                
                switch error {
                case .none, .other, .operationNotAllowed:
                    state.submitError = error?.errorMessage
                    
                case .emailAlreadyInUse, .invalidEmail:
                    state.formState.validationErrors[.email] = [error!.errorMessage]
                    
                case .weakPassword:
                    state.formState.validationErrors[.password] = [error!.errorMessage]
                }
                
                return .none
                
            case .binding, .form:
                return .none
            }
        }
        .form(\.formState) { field, state, errors in
            switch field {
            case .email: break
            case .password:
                errors[.password] = nil
                
                if state.password.count < 6 {
                    errors[.password] = ["Password must be 7 chars or longer"]
                }
            }
        }
    }
}

extension FestivlError.SignUpError {
    var errorMessage: String {
        switch self {
        case .operationNotAllowed, .other: "Failed to create account."
        case .emailAlreadyInUse: "Email already in use."
        case .invalidEmail: "Invalid email."
        case .weakPassword: "Weak password." // TODO: Investigate Firebase password reqs.
        }
    }
}
