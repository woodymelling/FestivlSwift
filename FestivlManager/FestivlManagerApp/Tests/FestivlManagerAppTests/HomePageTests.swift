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
    func testAuthFlowBinding() async {
        let store = TestStore(initialState: HomePageDomain.State()) {
            HomePageDomain()
        }
        
        await store.send(.binding(.set(\.$authFlow, .signIn))) {
            $0.authFlow = .signIn
        }

    }
}
