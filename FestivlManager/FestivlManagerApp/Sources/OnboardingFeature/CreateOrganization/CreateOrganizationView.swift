//
//  CreateOrganizationView.swift
//  
//
//  Created by Woodrow Melling on 8/7/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import PhotosUI
import ComposableArchitectureForms

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


