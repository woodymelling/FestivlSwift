//
//  FestivlManagerApp.swift
//  FestivlManager
//
//  Created by Woodrow Melling on 6/25/23.
//

import SwiftUI
import FestivlManagerApp
import FestivlDependencies
import FirebaseServiceImpl
import Models
import ComposableArchitecture

@main
struct FestivlManagerApp: App {
    init() {
        FirebaseServices.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FestivlManagerView(store: Store(initialState: .init()) {
                    FestivlManagerDomain()
                        ._printChanges()
                })
            }
        }
    }
}
