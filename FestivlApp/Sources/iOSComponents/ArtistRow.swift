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
//import FestivlDependencies


public struct ArtistRow: View {
    public init(artist: Artist, event: Event, stages: IdentifiedArrayOf<Stage>, sets: Set<ScheduleItem>, isFavorite: Bool, showArtistImage: Bool) {
        self.artist = artist
        self.event = event
        self.stages = stages
        self.sets = sets
        self.isFavorite = isFavorite
        self.showArtistImage = showArtistImage
    }


    let artist: Artist
    let event: Event
    let stages: IdentifiedArrayOf<Stage>
    let sets: Set<ScheduleItem>
    let isFavorite: Bool
    let showArtistImage: Bool

    public var body: some View {
        HStack(spacing: 10) {

            if showArtistImage {
               
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
        .frame(height: 60)
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
