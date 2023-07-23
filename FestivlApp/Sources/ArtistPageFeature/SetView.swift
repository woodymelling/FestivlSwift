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
    public init(set: ScheduleItem) {
        self.set = set
    }

    var set: ScheduleItem

    public var body: some View {
        
        ZStack {
            NavigationLink(destination: { EmptyView() }, label: { EmptyView() })

            // TODO: Row Spacing Signleton FestivlTheme
            HStack(spacing: 10) {
                StagesIndicatorView(stageIDs: [set.stageID])
                    .frame(width: 5)

                StageIconView(stageID: set.stageID)
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
            SetView(set: ScheduleItem.previewData().first!)
        }
        .listStyle(.plain)
        .previewAllColorModes()
    }
}
