//
//  SignIntests.swift
//  
//
//  Created by Woodrow Melling on 8/2/23.
//

import XCTest
@testable import OnboardingFeature
import ComposableArchitecture
import FestivlDependencies

@MainActor
final class SignInTests: XCTestCase {
    func testSignInHappyPath() async {
        let testEmail = "bob@festivl.live"
        let testPassword = "qwer1234"
        
        let store = TestStore(initialState: SignInDomain.State()) {
            SignInDomain()
        } withDependencies: {
            $0.sessionClient.signIn = {
                XCTAssert($0.email == testEmail)
                XCTAssert($0.password == testPassword)

                return "12345"
            }
        }
        
        await store.send(.binding(.set(\.$email, testEmail))) {
            $0.email = testEmail
        }
        
        await store.send(.binding(.set(\.$password, testPassword))) {
            $0.password = testPassword
        }
        
        await store.send(.form(.submittedForm)) {
            $0.isSigningIn = true
        }
        
        await store.receive(.successfullySignedIn("12345")) {
            $0.isSigningIn = false
        }
    }
    
    // MARK: Errors
    func testSignInEmailErrorMessage() async {
        let store = TestStore(initialState: SignInDomain.State()) {
            SignInDomain()
        } withDependencies: {
            $0.sessionClient.signIn = { _ in
                throw FestivlError.SignInError.invalidEmail
            }
        }
        
        await store.send(.form(.submittedForm)) {
            $0.isSigningIn = true
        }
        
        await store.receive(.failedToSignIn(.invalidEmail)) {
            $0.isSigningIn = false
            $0.formState.validationErrors[.email] = ["Unrecognized email address."]
        }
    }
    
    func testSignInPasswordErrorMessage() async {
        let store = TestStore(initialState: SignInDomain.State()) {
            SignInDomain()
        } withDependencies: {
            $0.sessionClient.signIn = { _ in
                throw FestivlError.SignInError.wrongPassword
            }
        }
        
        await store.send(.form(.submittedForm)) {
            $0.isSigningIn = true
        }
        
        await store.receive(.failedToSignIn(.wrongPassword)) {
            $0.isSigningIn = false
            $0.formState.validationErrors[.password] = ["Incorrect password."]
        }
    }
    
    func testSignInOtherErrorMessage() async {
        let store = TestStore(initialState: SignInDomain.State()) {
            SignInDomain()
        } withDependencies: {
            $0.sessionClient.signIn = { _ in
                throw FestivlError.SignInError.other
            }
        }
        
        await store.send(.form(.submittedForm)) {
            $0.isSigningIn = true
        }
        
        await store.receive(.failedToSignIn(.other)) {
            $0.isSigningIn = false
            $0.submitError = "Failed to sign in."
        }
    }
}
