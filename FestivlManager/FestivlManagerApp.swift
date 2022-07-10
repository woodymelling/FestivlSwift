//
//  FestivlManagerApp.swift
//  FestivlManager
//
//  Created by Woody on 3/8/22.
//

import SwiftUI
import ServiceCore
import FestivlManagerAppFeature
import MacOSComponents
import FirebaseFirestore

@main
struct FestivlManagerApp: App {

    init() {
        FirebaseServices.initialize(enablePersistance: false)
            
        
    }

    @State var image: NSImage?

    var body: some Scene {
        WindowGroup {
//            ImagePicker(outputImage: $image)
            FestivlManagerAppView(
                store: .init(
                    initialState: .init(eventListState: .init(addEventState: nil)),
                    reducer: festivlManagerAppReducer,
                    environment: .init()
                )
            )
        }
    }
}
