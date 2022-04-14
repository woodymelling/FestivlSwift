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
    var isSelected: Bool

    init(_ card: AnyStageScheduleCardRepresentable, stages: IdentifiedArrayOf<Stage>, isSelected: Bool) {
        self.card = card
        self.stageColor = stages[id: card.stageID]!.color
        self.isSelected = isSelected
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
        .border(.white, width: isSelected ? 1 : 0 )
    }
}

struct ArtistSetCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleCardView(ArtistSet.testValues()[0].asAnyStageScheduleCardRepresentable(), stages: Stage.testValues.asIdentifedArray, isSelected: false)
            .frame(width: 300, height: 100)
            .previewLayout(.sizeThatFits)
            .previewAllColorModes()
    }
}
