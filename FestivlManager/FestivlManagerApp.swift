//
//  FestivlManagerApp.swift
//  FestivlManager
//
//  Created by Woody on 3/8/22.
//

import SwiftUI
import ServiceCore
import FestivlManagerAppFeature

@main
struct FestivlManagerApp: App {

    init() {
        FirebaseServices.initialize()
    }

    var body: some Scene {
        WindowGroup {
            FestivlManagerAppView(
                store: .init(
                    initialState: .init(eventListState: .init()),
                    reducer: festivlManagerAppReducer,
                    environment: .init()
                )
            )
        }
    }
}
