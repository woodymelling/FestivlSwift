//
//  OnboardingDomain.swift
//  
//
//  Created by Woodrow Melling on 8/13/23.
//

import Foundation
import ComposableArchitecture
import Models

public struct OnboardingDomain: Reducer {
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
            Scope(state: /State.createOrganization, action: /Action.createOrganization) {
                CreateOrganizationDomain()
            }

            Scope(state: /State.createEvent, action: /Action.createEvent) {
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
        .forEach(\.path, action: /Action.path) {
            Path()
        }

        Scope(state: \State.startPage, action: /Action.startPage) {
            StartPageDomain()
        }
    }



}

extension OnboardingDomain.State {
    func saveOnboardingData() -> EffectOf<OnboardingDomain> {

        @Dependency(\.remoteImageClient) var remoteImageClient
        @Dependency(\.organizationClient) var organizationClient
        @Dependency(\.eventClient) var eventClient
        @Dependency(\.uuid) var uuid

        guard let createEventState = self.path.first(/OnboardingDomain.Path.State.createEvent),
              let createOrganizationState = self.path.first(/OnboardingDomain.Path.State.createOrganization),
              let userID = self.userID
        else {
            return .send(.failedToOnboard)
        }

        return .run { send in
            let imageURL: URL? = if let selectedPhoto = createEventState.eventImage.pickerItem {
                try await remoteImageClient.uploadImage(selectedPhoto, uuid().uuidString)
            } else {
                nil
            }

            let organization = try await organizationClient.createOrganization(
                name: createOrganizationState.name,
                imageURL: imageURL, // Use the image from the event when going through onboarding.
                owner: userID
            )

            // Have to manually wrap the withDependencies here, and probably only here
            // This is because createEvent depends on having an organization ID, but we just created the organization.
            // In other spots we should be in a place in the dependency tree where the organizationID is populated.
            try await withDependencies {
                $0.organizationID = organization.id
            } operation: {
                let eventID = try await eventClient.createEvent(
                    name: createOrganizationState.name, // Use the name from the organization when going through onboarding.
                    startDate: createEventState.startDate.calendarDate,
                    endDate: createEventState.endDate.calendarDate,
                    dayStartsAtNoon: createEventState.dayStartsAtNoon,
                    timeZone: createEventState.timeZone,
                    imageURL: imageURL
                )

                await send(.finishedSaving(organization, eventID))
            }
        }
    }
}

extension Collection {
    public func first<ElementOfResult>(
        _ transform: (Self.Element) throws -> ElementOfResult?
    ) rethrows -> ElementOfResult? {
        try self.compactMap(transform).first
    }
}

import Combine
enum AsyncError: Error {
    case finishedWithoutValue
}
extension Publisher {
    func firstValue() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(throwing: AsyncError.finishedWithoutValue)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }
}
