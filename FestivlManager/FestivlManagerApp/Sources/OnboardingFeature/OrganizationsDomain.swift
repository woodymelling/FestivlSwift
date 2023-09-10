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



public struct OrganizationsDomain: Reducer {
    public init() {}
    
    public struct State: Equatable {
        public init() {}
        
        var organizations: IdentifiedArrayOf<Organization> = []
        @BindingState var searchText: String = ""
        
        var isLoading: Bool = false

        @PresentationState var destination: Destination.State?
    }

    public struct Destination: Reducer {
        public init() {}

        public enum State: Equatable {
            case onboarding(OnboardingDomain.State)
        }

        public enum Action: Equatable {
            case onboarding(OnboardingDomain.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: /State.onboarding, action: /Action.onboarding) {
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
