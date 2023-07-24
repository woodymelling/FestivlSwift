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
import Collections
//import FestivlDependencies


public struct ArtistRow: View {
    public init(artist: Artist, event: Event, sets: OrderedSet<ScheduleItem>, isFavorite: Bool, showArtistImage: Bool) {
        self.artist = artist
        self.event = event
        self.sets = sets
        self.isFavorite = isFavorite
        self.showArtistImage = showArtistImage
    }

    let artist: Artist
    let event: Event
    let sets: OrderedSet<ScheduleItem>
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
                .aspectRatio(contentMode: .fill)
                .frame(square: 60)
                .clipped()
            }

            StagesIndicatorView(stageIDs: sets.map(\.stageID))
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
        NavigationStack {
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
    }
}
