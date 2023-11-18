import ComposableArchitecture
import Foundation

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
