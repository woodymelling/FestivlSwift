//
//  HomePageTests.swift
//  
//
//  Created by Woodrow Melling on 8/2/23.
//

import XCTest
@testable import FestivlManagerApp
import ComposableArchitecture
import FestivlDependencies

@MainActor
final class HomePageTests: XCTestCase {
    func testSignInButton() async {
        let store = TestStore(initialState: HomePageDomain.State()) {
            HomePageDomain()
        }
        
        await store.send(.didTapSignInButton) {
            $0.destination = .signIn(SignInDomain.State())
        }
        
        await store.send(.destination(.dismiss))  {
            $0.destination = nil
        }
    }
    
    func testSignUpdomain() async {
        let store = TestStore(initialState: HomePageDomain.State()) {
            HomePageDomain()
        }
        
        await store.send(.didTapSignUpButton) {
            $0.destination = .signUp(SignUpDomain.State())
        }
    }
}
