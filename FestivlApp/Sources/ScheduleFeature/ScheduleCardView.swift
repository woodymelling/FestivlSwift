//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/20/22.
//

import SwiftUI
import Models
import Utilities
import Components
import ComposableArchitecture

struct ScheduleCardView: View {
    var card: AnyStageScheduleCardRepresentable
    var stageColor: Color

    init(_ card: AnyStageScheduleCardRepresentable, stages: IdentifiedArrayOf<Stage>) {
        self.card = card
        self.stageColor = stages[id: card.stageID]!.color
    }

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.primary)
                .frame(height: 1)
                .opacity(0.25)

            HStack {
                Rectangle() 
                    .fill(.primary)
                    .frame(width: 5)
                    .opacity(0.25)

                GeometryReader { geo in
                    VStack(alignment: .leading) {

                        let hideArtistName = geo.size.height < 15
                        let hideSetTime = geo.size.height < 30
                        Text(card.title)
                            .isHidden(hideArtistName, remove: hideArtistName)

                        if let subtext = card.subtext {
                            Text(subtext)
                                .font(.caption)
                        }

                        Text(FestivlFormatting.timeIntervalFormat(startTime: card.startTime, endTime: card.endTime))
                            .font(.caption)
                            .isHidden(hideSetTime, remove: hideSetTime)
                    }
                    .foregroundColor(stageColor.isDarkColor ? .white : .black)
                }

                Spacer()
            }


        }
        .frame(maxWidth: .infinity)
        .background(stageColor)
    }
}

struct ArtistSetCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleCardView(ArtistSet.testValues()[0].asAnyStageScheduleCardRepresentable(), stages: Stage.testValues.asIdentifedArray)
            .frame(width: 300, height: 100)
            .previewLayout(.sizeThatFits)
            .previewAllColorModes()
    }
}
