//
//  WickedWoodsApp.swift
//  WickedWoods
//
//  Created by Woodrow Melling on 4/23/22.
//

import SwiftUI
import ComposableArchitecture
import FirebaseServiceImpl
import EventFeature
import FestivlDependencies

@main
struct WickedWoodsApp: App {

    init() {
        FirebaseServices.initialize()
        UserDefaultStore.shared.eventID = "NLL2bpmp0IkYF2tohlsI"
        
    }
    
    var body: some Scene {
        WindowGroup {
            EventView(
                store: Store(
                    initialState: .init(selectedTab: .more),
                    reducer: EventFeature()
                        .dependency(\.isEventSpecificApplication, true)
//                        ._printChanges()
//                        .dependency(\.userFavoritesClient, .liveValue)
//                        .dependency(\.eventID, "uxKxjEQe1RDi5AzB9zZI")
                )
            )
        }
    }
}
