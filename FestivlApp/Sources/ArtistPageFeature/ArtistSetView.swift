//
//  ArtistSetView.swift
//  
//
//  Created by Woody on 2/16/22.
//

import SwiftUI
import Models
import Components
import ComposableArchitecture

struct ArtistSetView: View {
    var set: ArtistSet
    var stages: IdentifiedArrayOf<Stage>

    var body: some View {
        HStack(spacing: 10) {
            let stage = stages[id: set.stageID]!
            
            StagesIndicatorView(stages: [stage])
                .frame(width: 5)

            StageIconView(stage: stage)
                .frame(square: 60)

            VStack(alignment: .leading) {
                Text(
                    FestivlFormatting.timeIntervalFormat(
                        startTime: set.startTime,
                        endTime: set.endTime
                    )
                )

                Text(
                    FestivlFormatting.timeOfDayFormat(for: set.startTime)
                )
                    .font(.caption)
                    .foregroundColor(.secondary)
                
            }

            Spacer()
        }
        .padding(.horizontal, 5)
        .frame(height: 60)
    }
}

struct ArtistSetViewView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ArtistSetView(set: .testData, stages: IdentifiedArray(uniqueElements: Stage.testValues))
        }
        .listStyle(.plain)
        .previewAllColorModes()
    }
}
