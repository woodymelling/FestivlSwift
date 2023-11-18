//
//  FestivalsDomain.swift
//  
//
//  Created by Woodrow Melling on 8/2/23.
//

import Foundation
import ComposableArchitecture
import FestivlDependencies
import Models
import SwiftUI
import Components
import Utilities

@Reducer
public struct OrganizationsDomain {
    public init() {}
    
    public struct State: Equatable {
        public init() {}
        
        var organizations: IdentifiedArrayOf<Organization> = []
        @BindingState var searchText: String = ""
        
        var isLoading: Bool = false

        @PresentationState var destination: Destination.State?
    }

    @Reducer
    public struct Destination {
        public init() {}

        public enum State: Equatable {
            case onboarding(OnboardingDomain.State)
        }

        public enum Action: Equatable {
            case onboarding(OnboardingDomain.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.onboarding, action: \.onboarding) {
                OnboardingDomain()
            }
        }
    }

    public enum Action: BindableAction, Equatable {
        case task
        case binding(BindingAction<State>)
        case dataUpdate(DataUpdate)
        case destination(PresentationAction<Destination.Action>)

        case didTapOrganization
        case didTapCreateOrganization

        case didTapSignOut
        
        public enum DataUpdate: Equatable {
            case orginizations(IdentifiedArrayOf<Organization>)
        }
    }
    
    @Dependency(\.organizationClient) var organizationClient
    @Dependency(\.sessionClient.signOut) var signOut
        
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding, .destination:
                return.none
                
            case .task:
                return .observe(organizationClient.observeMyOrganizations()) { .dataUpdate(.orginizations($0)) }

            case .dataUpdate(let dataType):
                switch dataType {
                case let .orginizations(festivals):
                    state.organizations = festivals
                }
                
                return .none
                
            case .didTapSignOut:
                return .run { _ in
                    try await signOut()
                }
                
            case .didTapOrganization:
                return .none

            case .didTapCreateOrganization:
                state.destination = .onboarding(.init())
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

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
                store: store.scope(state: \.$destination.onboarding, action: \.destination.onboarding),
                content: OnboardingView.init
            )
        }
    }
}

#Preview {
    NavigationStack {

        OrganizationsView(store: Store(initialState: OrganizationsDomain.State()) {
            OrganizationsDomain()
        })
    }
}

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
