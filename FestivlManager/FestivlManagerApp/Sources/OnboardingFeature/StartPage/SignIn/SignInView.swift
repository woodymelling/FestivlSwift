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
