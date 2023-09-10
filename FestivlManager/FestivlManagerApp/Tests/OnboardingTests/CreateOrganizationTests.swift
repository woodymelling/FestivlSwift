//
//  File.swift
//  
//
//  Created by Woodrow Melling on 8/26/23.
//

import Foundation
import XCTest
@testable import OnboardingFeature
import ComposableArchitecture

@MainActor
class CreateOrganizationTests: XCTestCase {
    func testHappyPath() async {
        let store = TestStore(initialState: CreateOrganizationDomain.State()) {
            CreateOrganizationDomain()
        }

        await store.send(.binding(.set(\.$name, "Testival"))) {
            $0.name = "Testival"
        }

        await store.send(.didTapCreateButton)

        await store.receive(.delegate(.didSubmitForm))
    }

    func testFieldSubmit() async {
        let store = TestStore(initialState: CreateOrganizationDomain.State()) {
            CreateOrganizationDomain()
        }

        await store.send(.didSubmitField(.name))

        await store.receive(.delegate(.didSubmitForm))
    }
}
