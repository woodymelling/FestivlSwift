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
import ScheduleComponents

struct ScheduleCardView: View {
    let card: ScheduleItem
    let isSelected: Bool
    let isFavorite: Bool

    @ScaledMetric var scale: CGFloat = 1

    public init(_ card: ScheduleItem, isSelected: Bool, isFavorite: Bool) {
        self.card = card
        self.isSelected = isSelected
        self.isFavorite = isFavorite
    }
    
    @Environment(\.stages) var stages
    
    public var body: some View {
        ScheduleCardBackground(color: stages[id: card.stageID]!.color, isSelected: isSelected) {
            HStack(alignment: .center) {
                
                GeometryReader { geo in
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
        }
        .id(card.id)
        .tag(card.id)
    }
 
}
