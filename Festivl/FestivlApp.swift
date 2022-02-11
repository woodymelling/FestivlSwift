//
//  FestivlApp.swift
//  Festivl
//
//  Created by Woody on 2/9/22.
//

import SwiftUI
import ServiceCore

@main
struct FestivlApp: App {

    init() {
        FirebaseServices.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
