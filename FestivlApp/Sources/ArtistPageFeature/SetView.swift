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

public struct SetView: View {
    public init(set: ScheduleItem, stages: IdentifiedArrayOf<Stage>) {
        self.set = set
        self.stages = stages
    }

    var set: ScheduleItem
    var stages: IdentifiedArrayOf<Stage>

    public var body: some View {
        
        ZStack {
            NavigationLink(destination: { EmptyView() }, label: { EmptyView() })

            // TODO: Row Spacing Signleton FestivlTheme
            HStack(spacing: 10) {
                let stage = stages[id: set.stageID]!

                StagesIndicatorView(stages: [stage])
                    .frame(width: 5)

                StageIconView(stage: stage)
                    .frame(square: 60)

                switch set.type {
                case .artistSet:
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

                case .groupSet:
                    VStack(alignment: .leading) {
                        Text(set.title)

                        Text(
                            FestivlFormatting.timeIntervalFormat(
                                startTime: set.startTime,
                                endTime: set.endTime
                            ) + " " + FestivlFormatting.timeOfDayFormat(for: set.startTime)
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 5)
        .frame(height: 60)
        }
    }
}

struct ArtistSetViewView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SetView(set: ArtistSet.testData.asScheduleItem(), stages: IdentifiedArray(uniqueElements: Stage.testValues))
        }
        .listStyle(.plain)
        .previewAllColorModes()
    }
}
