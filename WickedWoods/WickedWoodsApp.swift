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
    }
    
    var body: some Scene {
        WindowGroup {
            EventView(
                store: Store(
                    initialState: .init(),
                    reducer: {
                        EventFeature()
                            .dependency(\.eventID, "NLL2bpmp0IkYF2tohlsI")
                    }
                )
            )
        }
    }
}
