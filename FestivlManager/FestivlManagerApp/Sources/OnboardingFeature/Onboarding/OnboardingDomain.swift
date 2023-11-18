//
//  OnboardingDomain.swift
//  
//
//  Created by Woodrow Melling on 8/13/23.
//

import Foundation
import ComposableArchitecture
import Models
import SwiftUI

@Reducer
public struct OnboardingDomain {
    public init() {}

    public struct State: Equatable {
        public init() {}

        var userID: User.ID?

        var path = StackState<Path.State>()
        var startPage: StartPageDomain.State = .init()
    }

    public enum Action: Equatable {
        case startPage(StartPageDomain.Action)
        case path(StackAction<Path.State, Path.Action>)

        case finishedSaving(Organization, Event.ID)

        case delegate(Delegate)

        case failedToOnboard
        case loggedInWithNoOrganizations

        public enum Delegate: Equatable {
            case didFinishOnboarding(Organization, Event.ID)
        }
    }

    @Reducer
    public struct Path: Reducer {
        public enum State: Equatable {
            case createOrganization(CreateOrganizationDomain.State)
            case createEvent(CreateEventDomain.State)
        }

        public enum Action: Equatable {
            case createOrganization(CreateOrganizationDomain.Action)
            case createEvent(CreateEventDomain.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.createOrganization, action: \.createOrganization) {
                CreateOrganizationDomain()
            }

            Scope(state: \.createEvent, action: \.createEvent) {
                CreateEventDomain()
            }
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.organizationClient) var organizationClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .startPage(.delegate(.didSignIn(userID))),
                 let .startPage(.delegate(.didSignUp(userID))):
                state.userID = userID
                // TODO: Check for organizations!
                return .run { send in
                    let organizations = try await organizationClient.observeMyOrganizations().firstValue()

                    if organizations.isEmpty {
                        await send(.loggedInWithNoOrganizations)
                    } else {
                        await self.dismiss()
                    }
                } catch: { error, send in
                    print(error)
                }


            case .loggedInWithNoOrganizations:
                state.path.append(.createOrganization(.init()))

                return .none

            case let .path(.element(id: _, action: action)):
                switch action {
                case .createOrganization(.delegate(let delegate)):
                    switch delegate {
                    case .didSubmitForm:
                        state.path.append(.createEvent(.init()))
                    }
                    return .none
                    
                case .createEvent(.delegate(.didFinishCreatingEvent)):

                    return state.saveOnboardingData()

                case .createOrganization, .createEvent:
                    return .none
                }
                
            case let .finishedSaving(organization, eventID):
                
                return .merge(
                    .run { _ in await self.dismiss() },
                    .send(.delegate(.didFinishOnboarding(organization, eventID)))
                )
            case .failedToOnboard:
                return .none

            case .path, .delegate, .startPage:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }

        Scope(state: \.startPage, action: \.startPage) {
            StartPageDomain()
        }
    }
}

public struct OnboardingView: View {
    let store: StoreOf<OnboardingDomain>

    public init(store: StoreOf<OnboardingDomain>) {
        self.store = store
    }

    public var body: some View {
        NavigationStackStore(self.store.scope(state: \.path, action: \.path)) {
            StartPageView(
                store: store.scope(state: \.startPage, action: \.startPage)
            )
        } destination: { state in
            switch state {
            case .createOrganization:
                CaseLet(
                    /OnboardingDomain.Path.State.createOrganization,
                     action: OnboardingDomain.Path.Action.createOrganization,
                     then: CreateOrganizationView.init
                )
            case .createEvent:
                CaseLet(
                    /OnboardingDomain.Path.State.createEvent,
                    action: OnboardingDomain.Path.Action.createEvent,
                    then: CreateEventView.init
                )
            }
        }
    }
}


#Preview {
    Text("Blah")
        .sheet(isPresented: .constant(true), content: {
            OnboardingView(store: Store(initialState: OnboardingDomain.State()) {
                OnboardingDomain()
                    ._printChanges()
            })
        })

}
