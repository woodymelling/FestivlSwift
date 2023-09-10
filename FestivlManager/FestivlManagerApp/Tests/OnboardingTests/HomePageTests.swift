//
//  HomePageTests.swift
//  
//
//  Created by Woodrow Melling on 8/2/23.
//

import XCTest
@testable import OnboardingFeature
import ComposableArchitecture
import FestivlDependencies

@MainActor
final class StartPageTests: XCTestCase {
    func testAuthFlowBinding() async {
        let store = TestStore(initialState: StartPageDomain.State()) {
            StartPageDomain()
        }

        await store.send(.binding(.set(\.$authFlow, .signIn))) {
            $0.authFlow = .signIn
        }

        await store.send(.binding(.set(\.$authFlow, .signUp))) {
            $0.authFlow = .signUp
        }
    }

    func testSignIn() async {
        let store = TestStore(initialState: StartPageDomain.State()) {
            StartPageDomain()
        } withDependencies: {
            $0.sessionClient.signIn = { _ in
                "12345"
            }
        }

        store.exhaustivity = .off

        await store.send(.signIn(.binding(.set(\.$email, "woody@festivl.live"))))
        await store.send(.signIn(.binding(.set(\.$password, "qwer1234"))))

        await store.send(.signIn(.form(.submittedForm)))

        await store.receive(.delegate(.didSignIn("12345")))
    }

    func testSignUp() async {
        let store = TestStore(initialState: StartPageDomain.State()) {
            StartPageDomain()
        } withDependencies: {
            $0.sessionClient.signUp = { _ in
                "12345"
            }
        }

        store.exhaustivity = .off

        await store.send(.signUp(.binding(.set(\.$email, "woody@festivl.live"))))
        await store.send(.signUp(.binding(.set(\.$password, "qwer1234"))))

        await store.send(.signUp(.form(.submittedForm)))

        await store.receive(.delegate(.didSignUp("12345")))
    }
}
