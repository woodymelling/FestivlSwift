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
import Models
import SwiftUI

@Reducer
public struct SignInDomain {
    public struct State: Equatable, HasFormState {
        
        public init() {}
        
        @BindingState var email: String = "woodymelling@gmail.com"
        @BindingState var password: String = "wmelling3618"

        public var formState: FormState<Field> = .init()
        var submitError: String?
        
        var isSigningIn = false
    }
    
    public enum Action: Equatable, BindableAction, HasFormAction {
        case binding(BindingAction<State>)
        case form(FormAction<State, Field>)
        
        case successfullySignedIn(User.ID)
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
    
    @Dependency(\.sessionClient.signIn) var signIn

    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .form(.submittedForm):
                state.isSigningIn = true
                
                return .run { [password = state.password, email = state.email] send in
                    let userID = try await self.signIn(SignInUpData(email: email, password: password))

                    await send(.successfullySignedIn(userID))
                    
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


struct SignInView: View {
    let store: StoreOf<SignInDomain>

    struct ViewState: Equatable {
        @BindingViewState var email: String
        @BindingViewState var password: String

        var formState: FormState<SignInDomain.Field>
        var submitError: String?
        var isSigningIn: Bool

        init(state: BindingViewStore<SignInDomain.State>) {
            self._email = state.$email
            self._password = state.$password
            self.formState = state.formState
            self.submitError = state.submitError
            self.isSigningIn = state.isSigningIn
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
                        if viewStore.isSigningIn {
                            ProgressView()
                        } else {
                            Text("Sign in")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewStore.isSigningIn)
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
        SignInView(
            store: .init(
                initialState: .init(),
                reducer: SignInDomain.init
            )
        )
    }
}
