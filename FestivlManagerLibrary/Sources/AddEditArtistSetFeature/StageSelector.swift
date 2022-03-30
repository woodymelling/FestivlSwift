//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/30/22.
//

import SwiftUI
import IdentifiedCollections
import Models

struct StageSelector: View {
    var stages: IdentifiedArrayOf<Stage>
    @Binding var selectedStage: Stage?

    var body: some View {
        Picker("Stage", selection: $selectedStage, content: {
            ForEach(stages) { stage in
                Text(stage.name).tag(stage as Stage?)
            }
        })
    }
}
