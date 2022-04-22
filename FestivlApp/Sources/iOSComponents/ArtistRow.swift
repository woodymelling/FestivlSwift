//
//  ArtistRow.swift
//  
//
//  Created by Woody on 2/9/22.
//

import SwiftUI
import Models
import Utilities
import Components
import IdentifiedCollections


public struct ArtistRow: View {
    public init(artist: Artist, event: Event, stages: IdentifiedArrayOf<Stage>, sets: IdentifiedArrayOf<ScheduleItem>, isFavorite: Bool) {
        self.artist = artist
        self.event = event
        self.stages = stages
        self.sets = sets
        self.isFavorite = isFavorite
    }


    var artist: Artist
    var event: Event
    var stages: IdentifiedArrayOf<Stage>
    var sets: IdentifiedArrayOf<ScheduleItem>
    var isFavorite: Bool

    public var body: some View {
        HStack(spacing: 10) {

            Group {
                CachedAsyncImage(url: artist.imageURL, placeholder: {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(square: 30)

                })
                .frame(square: 60)
            }

            StagesIndicatorView(
                stages: sets.compactMap {
                    stages[id: $0.stageID]
                }
            )
            .frame(width: 5)

            Text(artist.name)
                .lineLimit(1)

            Spacer()

            if isFavorite {
                Image(systemName: "heart.fill")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(square: 15)
                    .foregroundColor(.accentColor)
                    .padding(.trailing)
            }

        }
    }

}

struct ArtistRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                ForEach(Array(0...10), id: \.self) { _ in
                    NavigationLink(destination: EmptyView()) {
//                        ArtistRow(artist: Artist.testData, event: .testData)
                    }

                }
            }
            .listStyle(.plain)
            .navigationTitle("Artists")

        }
        .previewAllColorModes()

    }
}