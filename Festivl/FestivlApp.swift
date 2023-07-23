//
//  FestivlApp.swift
//  Festivl
//
//  Created by Woody on 2/9/22.
//

import SwiftUI
import FirebaseServiceImpl
import FestivlDependencies
import FestivlAppFeature

@main
struct FestivlApp: App {

    init() {
        FirebaseServices.initialize()
        
        _ = EventClientKey.liveValue
    }

    var body: some Scene {
        WindowGroup {
            AppView(
                store: .init(
                    initialState: .init(),
                    reducer: {
                        AppFeature().dependency(\.currentEnvironment, .test)
                    }
                )
            )
        }
    }
}
