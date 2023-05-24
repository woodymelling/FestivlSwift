//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/20/22.
//

import SwiftUI
import Utilities
import Components
import ComposableArchitecture
import Models

public struct ScheduleCardView: View {

    
    let card: ScheduleItem
    let isSelected: Bool

    @ScaledMetric var scale: CGFloat = 1

    public init(_ card: ScheduleItem, isSelected: Bool) {
        self.card = card
        self.isSelected = isSelected
    }
    
    
    public var body: some View {
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
                        .padding(.top, 2)
                    }
                }

                Spacer()

                if card.isFavorite {
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
        .background(card.stage.color)
        .border(.white, width: isSelected ? 1 : 0 )
    }
}
