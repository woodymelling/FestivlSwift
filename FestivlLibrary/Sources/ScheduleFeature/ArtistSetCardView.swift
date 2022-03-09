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

struct ArtistSetCardView: View {
    var artistSet: ArtistSet
    var stageColor: Color

    init(artistSet: ArtistSet, stages: IdentifiedArrayOf<Stage>) {
        self.artistSet = artistSet
        self.stageColor = stages[id: artistSet.stageID]!.color
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
                        Text(artistSet.artistName)
                            .isHidden(hideArtistName, remove: hideArtistName)

                        Text(FestivlFormatting.timeIntervalFormat(startTime: artistSet.startTime, endTime: artistSet.endTime))
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
        ArtistSetCardView(artistSet: .testValues()[0], stages: Stage.testValues.asIdentifedArray)
            .frame(width: 300, height: 100)
            .previewLayout(.sizeThatFits)
            .previewAllColorModes()
    }
}
