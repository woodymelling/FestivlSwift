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
    var card: ScheduleItem
    var stageColor: Color
    var isSelected: Bool

    @ScaledMetric var scale: CGFloat = 1

    init(_ card: ScheduleItem, stages: IdentifiedArrayOf<Stage>, isSelected: Bool) {
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
                    Group {

                        if geo.size.height < 31 * scale {
                            HStack {
                                Text(card.title)
                                Text(FestivlFormatting.timeIntervalFormat(startTime: card.startTime, endTime: card.endTime))
                                    .font(.caption)
                            }
                        } else {

                            VStack(alignment: .leading) {
                                Text(card.title)
                                Text(FestivlFormatting.timeIntervalFormat(startTime: card.startTime, endTime: card.endTime))
                                    .font(.caption)
                            }
                        }
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
        ScheduleCardView(ArtistSet.testValues()[0].asScheduleItem(), stages: Stage.testValues.asIdentifedArray, isSelected: false)
            .frame(width: 300, height: 100)
            .previewLayout(.sizeThatFits)
            .previewAllColorModes()
    }
}
