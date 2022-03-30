//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/29/22.
//

import Foundation
import SwiftUI
import Models

struct ArtistSetCardView: View {
    var artistSet: ArtistSet
    var stage: Stage

    @Environment(\.colorScheme) var colorScheme

    var primaryColor: Color {
        stage.color
    }

    @ViewBuilder
    var secondaryColor: some View {
        switch colorScheme {
        case .light:
            primaryColor.colorMultiply(.black)
        case .dark:
            primaryColor.colorMultiply(.white)
        @unknown default:
            primaryColor.colorMultiply(.black)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(primaryColor)
                .brightness(colorScheme == .light ? -0.1 : 0.3)

            HStack {
                Rectangle()
                    .frame(width: 4)
                    .foregroundColor(primaryColor)
                    .brightness(colorScheme == .light ? -0.1 : 0.3)

                GeometryReader { geo in
                    VStack(alignment: .leading) {

                        let hideArtistName = geo.size.height < 15
                        let hideSetTime = geo.size.height < 30
                        Text(artistSet.artistName)
                            .isHidden(hideArtistName, remove: hideArtistName)

                        Text(artistSet.startTime...artistSet.endTime)
                            .font(.caption)
                            .isHidden(hideSetTime, remove: hideSetTime)
                    }
                }

                Spacer()
            }
            .background(primaryColor)
        }

    }
}

struct ArtistSetCardView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistSetCardView(
            artistSet: .testData,
            stage: .testData
        )
            .previewLayout(.fixed(width: 200, height: 200))
        .previewAllColorModes()
    }
}
