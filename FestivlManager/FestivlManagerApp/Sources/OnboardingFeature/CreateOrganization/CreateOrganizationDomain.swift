//
//  CreateOrganization.swift
//  
//
//  Created by Woodrow Melling on 8/7/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct CreateOrganizationDomain {
    public struct State: Equatable {
        public init() {}
        
        @BindingState var name: String = ""
        @BindingState var focusedField: Field? = .name

        public enum Field {
            case name
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case didTapCreateButton

        case didSubmitField(State.Field)

        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didSubmitForm
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding, .delegate:
                return .none

            case .didTapCreateButton, .didSubmitField(.name):

                return .send(.delegate(.didSubmitForm))
            }
        }
    }
}


struct CreateOrganizationView: View {
    let store: StoreOf<CreateOrganizationDomain>

    init(store: StoreOf<CreateOrganizationDomain>) {
        self.store = store
    }

    @FocusState var focusedField: CreateOrganizationDomain.State.Field?

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    TextField(
                        "What is your festival called?",
                        text: viewStore.$name
                    )
                    .focused($focusedField, equals: .name)
                    .onSubmit { viewStore.send(.didSubmitField(.name)) }

                } header: {
                    Spacer()
                }

                Section {} footer: {
                    Button {
                        viewStore.send(.didTapCreateButton)
                    } label: {
                        Text("Create")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Create your festival!")
            .bind(viewStore.$focusedField, to: $focusedField)
        }
    }
}

#Preview {
    NavigationStack {

        CreateOrganizationView(
            store: Store(initialState: CreateOrganizationDomain.State()) {
                CreateOrganizationDomain()
            }
        )
    }
}


