//
//  MyEventsView.swift
//  
//
//  Created by Woodrow Melling on 8/2/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Components
import Utilities

public struct OrganizationsView: View {
    public init(store: StoreOf<OrganizationsDomain>) {
        self.store = store
    }
    
    let store: StoreOf<OrganizationsDomain>
    
    public var body: some View {
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            SimpleSearchableList(
                data: viewStore.organizations,
                searchText: viewStore.$searchText,
                isLoading: viewStore.isLoading
            ) { organization in
                Button {
                    viewStore.send(.didTapOrganization)
                } label: {
                    HStack {
                        CachedAsyncIcon(url: organization.imageURL) {
                            ZStack {
                                ProgressView()
                                    .opacity(0.01)
                            }
                        }
                        .frame(square: 50)
                        
                        Text(organization.name)
                            .font(.headline)
                    }
                }
            } emptyContent: {
                Button {
                    viewStore.send(.didTapCreateOrganization)
                } label: {
                    Text("Create a Festival")
                }
            }
            .task { await store.send(.task).finish() }
            .listStyle(.plain)
            .navigationTitle("My Festivals")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button("Logout") {
                            viewStore.send(.didTapSignOut)
                        }
                    } label: {
                        Label("Profile", systemImage: "person.circle")
                    }
                }

                ToolbarItem {
                    Button("Create Organization", systemImage: "plus") {
                        viewStore.send(.didTapCreateOrganization)
                    }
                }
            }
            .fullScreenCover(
                store: destinationStore,
                state: /OrganizationsDomain.Destination.State.onboarding,
                action: OrganizationsDomain.Destination.Action.onboarding,
                content: OnboardingView.init
            )
        }
    }

    var destinationStore: PresentationStoreOf<OrganizationsDomain.Destination> {
        self.store.scope(
            state: \.$destination,
            action: OrganizationsDomain.Action.destination
        )
    }
}

#Preview {
    NavigationStack {
        
        OrganizationsView(store: Store(initialState: OrganizationsDomain.State()) {
            OrganizationsDomain()
        })
    }
}


import Combine
#Preview("Empty") {
    NavigationStack {
        
        OrganizationsView(store: Store(initialState: OrganizationsDomain.State()) {
            OrganizationsDomain()
                .transformDependency(\.organizationClient) {
                    $0.observeMyOrganizations = {
                        Just([]).eraseToDataStream()
                    }
                }
            
        })
    }
}

