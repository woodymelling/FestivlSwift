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
    var isFavorite: Bool

    @ScaledMetric var scale: CGFloat = 1

    init(_ card: ScheduleItem, stages: IdentifiedArrayOf<Stage>, isSelected: Bool, isFavorite: Bool) {
        self.card = card
        self.stageColor = stages[id: card.stageID]!.color
        self.isSelected = isSelected
        self.isFavorite = isFavorite
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

                        // Arrange horizontally if the card is too small
                        if geo.size.height < 31 * scale {
                            HStack {
                                Text(card.title)
                                    .font(.caption)
                                Text(FestivlFormatting.timeIntervalFormat(startTime: card.startTime, endTime: card.endTime))
                                    .font(.caption)
                            }
                        } else {

                            VStack(alignment: .leading) {
                                Text(card.title)
                                Text(FestivlFormatting.timeIntervalFormat(startTime: card.startTime, endTime: card.endTime))
                                    .font(.caption)

                                if let subtext = card.subtext {
                                    Text(subtext)
                                        .font(.caption2)
                                }
                            }
                        }
                    }


                }

                Spacer()

                if isFavorite {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(square: 15)
                        .padding(.trailing)
                }


            }
            .foregroundColor(.white)
        }
        .clipped()
        .frame(maxWidth: .infinity)
        .background(stageColor)
        .border(.white, width: isSelected ? 1 : 0 )
    }
}

struct ArtistSetCardView_Previews: PreviewProvider {
    static var previews: some View {
        
        ScheduleCardView(
            .testValues().first!,
            stages: Stage.testValues.asIdentifedArray,
            isSelected: false,
            isFavorite: false
        )
        .frame(width: 300, height: 100)
        .previewLayout(.sizeThatFits)
    }
}
