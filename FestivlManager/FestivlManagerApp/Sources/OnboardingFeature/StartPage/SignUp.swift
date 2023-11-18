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

@Reducer
public struct SignUpDomain {
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
                
        case succesfullyCreatedAccount(User.ID)
        case failedToCreateAccount(FestivlError.SignUpError?)
    }
    
    @Dependency(\.sessionClient.signUp) var signUp

    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .form(.submittedForm):
                state.isCreatingAccount = true
                
                return .run { [password = state.password, email = state.email] send in
                    let userID = try await self.signUp(SignInUpData(email: email, password: password))

                    await send(.succesfullyCreatedAccount(userID))
                    
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


struct SignUpView: View {
    let store: StoreOf<SignUpDomain>

    struct ViewState: Equatable {
        @BindingViewState var email: String
        @BindingViewState var password: String

        var formState: FormState<SignUpDomain.Field>
        var submitError: String?
        var isCreatingAccount: Bool

        init(state: BindingViewStore<SignUpDomain.State>) {
            self._email = state.$email
            self._password = state.$password
            self.formState = state.formState
            self.submitError = state.submitError
            self.isCreatingAccount = state.isCreatingAccount
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            VStack {
                TextField("Email", text: viewStore.$email)
                    .validation(self.store, field: .email)

                SecureField("Password", text: viewStore.$password)
                    .validation(self.store, field: .password)

                Text(hiddenWhenNil: viewStore.submitError)
                    .foregroundStyle(Color.red)

                Button {
                    viewStore.send(.form(.submittedForm))
                } label: {
                    Group {
                        if viewStore.isCreatingAccount {
                            ProgressView()
                        } else {
                            Text(localized: "Sign up")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewStore.isCreatingAccount)
                .padding(.horizontal)

                Spacer()
            }
            .textFieldStyle(.roundedBorder)
            .animation(.default, value: viewStore.submitError)
            .animation(.default, value: viewStore.formState.validationErrors)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(store: .init(initialState: .init()) {
            SignUpDomain()
        })
    }
}
