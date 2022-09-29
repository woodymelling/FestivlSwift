//
//  FestivlApp.swift
//  Festivl
//
//  Created by Woody on 2/9/22.
//

import SwiftUI
import ServiceCore
import FestivlAppFeature

@main
struct FestivlApp: App {

    init() {
        FirebaseServices.initialize()
    
    }

    var body: some Scene {
        WindowGroup {
            AppView(
                store: .init(initialState: .init(isTestMode: false), reducer: AppFeature())
            )
        }
    }
}
