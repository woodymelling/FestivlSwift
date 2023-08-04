//
//  SignInView.swift
//
//
//  Created by Woodrow Melling on 7/29/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import ComposableArchitectureForms
import FestivlDependencies

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
//                .transformDependency(\.authenticationClient) {
//                    $0.signUp = { _ in
//                        try await Task.sleep(for: .seconds(1))
//                        throw FestivlError.SignUpError.emailAlreadyInUse
//                    }
//                }
        })
    }
}



