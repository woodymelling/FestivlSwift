//
//  OnboardingTests.swift
//  
//
//  Created by Woodrow Melling on 8/26/23.
//

import XCTest
@testable import OnboardingFeature
import ComposableArchitecture
import FestivlDependencies
import struct SwiftUI.Image
import PhotosUI

@MainActor
final class OnboardingTests: XCTestCase {

    func testSignInDismissesWhenPartOfOrganizations() async throws {
        let shouldDismissExpectation = expectation(description: "Should Dismiss")
        let store = TestStore(initialState: OnboardingDomain.State()) {
            OnboardingDomain()
        } withDependencies: {
            $0.sessionClient.signIn = { _ in
                return "id"
            }
            $0.organizationClient.observeMyOrganizations = {
                Just([Organization(id: "1", name: "Testival", userRoles: [:])]).eraseToDataStream()
            }
            $0.dismiss = .init({ shouldDismissExpectation.fulfill() })
        }

        store.exhaustivity = .off

        await store.send(.startPage(.signIn(.form(.submittedForm))))
        
        await fulfillment(of: [shouldDismissExpectation], timeout: 1.seconds)
    }

    func testSignInNavigatesWhenNotAPartOfOrganizations() async throws {
        let store = TestStore(initialState: OnboardingDomain.State()) {
            OnboardingDomain()
        } withDependencies: {
            $0.sessionClient.signIn = { _ in
                return "id"
            }
            $0.organizationClient.observeMyOrganizations = {
                Just([]).eraseToDataStream()
            }
        }

        store.exhaustivity = .off

        await store.send(.startPage(.signIn(.form(.submittedForm))))

        await store.skipReceivedActions()

        store.assert {
            $0.path[id: 0] = .createOrganization(CreateOrganizationDomain.State())
        }
    }

    // Very large test checking the entirety of the sign up flow.
    // Create an account, create an organization, create an event with an image,
    // Save that all to the backend
    // Dismiss the view
    func testSignUp() async throws {
        let user = User(id: .init("12345"), email: "blah@fetival.live")
        let today = Date.from(year: 2023, month: 08, day: 26)!
        let organizationName = "Testival"
        let organizationImage = Image(systemName: "eventImage")
        let festivalImageURL = URL(string: "https://festivl.live/image")!
        let festivalImagePickerItem = PhotosPickerItem(itemIdentifier: "eventImage")
        let organizationID = Organization.ID("1")
        let eventID = Event.ID("54321")

        let createEventExpectation = expectation(description: "Create Event")
        let createOrganizationExpectation = expectation(description: "Create Organization")
        let uploadImageExpectation = expectation(description: "Upload an Image")
        let loadTransferableExpectation = expectation(description: "Load Transferable")
        let dismissExpectation = expectation(description: "Dismiss at end of flow")

        let store = TestStore(initialState: OnboardingDomain.State()) {
            OnboardingDomain()
        } withDependencies: {
            $0.sessionClient.signUp = { _ in
                user.id
            }
            $0.date = .constant(today)
            $0.timeZone = .gmt
            $0.uuid = .incrementing

            $0.eventClient._createEvent = { event in
                createEventExpectation.fulfill()


                @Dependency(\.organizationID) var orgID
                XCTAssertEqual(orgID, organizationID)

                return eventID
            }

            $0.photosPickerClient.loadTransferable = { pickerItem in
                loadTransferableExpectation.fulfill()

                XCTAssertEqual(pickerItem, festivalImagePickerItem)

                return organizationImage
            }

            $0.organizationClient.observeMyOrganizations = {
                Just([]).eraseToDataStream()
            }

            $0.organizationClient.createOrganization = { name, imageURL, owner in
                createOrganizationExpectation.fulfill()

                XCTAssertEqual(name, organizationName)
                XCTAssertEqual(imageURL, festivalImageURL)
                XCTAssertEqual(owner, user.id)

                return Organization(id: organizationID, name: name, imageURL: imageURL, userRoles: [owner:.owner])
            }

            $0.remoteImageClient.uploadImage = { image, location in
                uploadImageExpectation.fulfill()
                
                return festivalImageURL
            }

            $0.dismiss = .init({ dismissExpectation.fulfill() })
        }

        store.exhaustivity = .off

        await store.send(.startPage(.signUp(.form(.submittedForm))))
        
        await store.receive(.startPage(.delegate(.didSignUp("12345"))))

        await store.skipReceivedActions()

        store.assert {
            $0.path[id: 0] = .createOrganization(CreateOrganizationDomain.State())
        }

        await store.send(
            .path(
                .element(
                    id: 0,
                    action: .createOrganization(.binding(.set(\.$name, "Testival")))
                )
            )
        )

        await store.send(
            .path(
                .element(
                    id: 0,
                    action: .createOrganization(.didTapCreateButton)
                )
            )
        )

        await store.receive(.path(.element(id: 0, action: .createOrganization(.delegate(.didSubmitForm))))) {

            $0.path[id: 1] = .createEvent(
                .init(
                    startDate: today,
                    endDate: today.addingTimeInterval(1.days),
                    timeZone: .gmt,
                    dayStartsAtNoon: false
                )
            )
        }

        await store.send(
            .path(
                .element(
                    id: 1,
                    action: .createEvent(
                        .binding(
                            .set(
                                \.$eventImage,
                                 .init(pickerItem: festivalImagePickerItem)
                            )
                        )
                    )
                )
            )
        )

        await store.send(
            .path(
                .element(
                    id: 1,
                    action: .createEvent(.didTapCreateEvent)
                )
            )
        )

        store.exhaustivity = .on

        await store.receive(
            .path(
                .element(
                    id: 1,
                    action: .createEvent(
                        .delegate(
                            .didFinishCreatingEvent
                        )
                    )
                )
            )
        )

        await store.receive(
            .finishedSaving(
                Organization(id: organizationID, name: organizationName, imageURL: festivalImageURL, userRoles: [user.id: .owner]),
                eventID
            )
        )

        await store.receive(
            .delegate(
                .didFinishOnboarding(
                    Organization(id: organizationID, name: organizationName, imageURL: festivalImageURL, userRoles: [user.id: .owner]),
                    eventID
                )
            )
        )
//
        await fulfillment(
            of: [
                createEventExpectation,
                createOrganizationExpectation,
                uploadImageExpectation,
                loadTransferableExpectation,
                dismissExpectation
            ],
            timeout: 1.seconds
        )
    }
}
