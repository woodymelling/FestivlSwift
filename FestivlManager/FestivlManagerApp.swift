//
//  FestivlManagerApp.swift
//  FestivlManager
//
//  Created by Woodrow Melling on 6/25/23.
//

import SwiftUI
import ScheduleManagementFeature
import FestivlDependencies
import FirebaseServiceImpl
import Models

@main
struct FestivlManagerApp: App {
    init() {
        FirebaseServices.initialize()
    }
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                
                ScheduleManagementView(
                    store: .init(
                        initialState: ScheduleManagementDomain.State(),
                        reducer: {
                            ScheduleManagementDomain()
//                                .dependency(\.eventClient, EventClientKey.previewValue)
//                                .dependency(\.stageClient, StageClientKey.previewValue)
//                                .dependency(\.scheduleClient, ScheduleClientKey.previewValue)
//                                .dependency(\.artistClient, ArtistClientKey.previewValue)
                                .dependency(\.eventID, "NLL2bpmp0IkYF2tohlsI")
                        }
                    )
                )
            }
        }
    }
}
