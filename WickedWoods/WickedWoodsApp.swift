//
//  WickedWoodsApp.swift
//  WickedWoods
//
//  Created by Woodrow Melling on 4/23/22.
//

import SwiftUI
import EventFeature
import ServiceCore

@main
struct WickedWoodsApp: App {

    init() {
        FirebaseServices.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            EventLoadingView(store: .live(eventID: "jS1o9Y8HFBhwOaaZmsZB", testMode: true))
        }
    }
}
