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

struct ArtistRow: View {
    var artist: Artist
    var event: Event
    var stages: IdentifiedArrayOf<Stage>
    var artistSets: IdentifiedArrayOf<ArtistSet>

    var body: some View {
        HStack(spacing: 10) {
            AsyncImage(url: artist.imageURL ?? event.imageURL, content: { phase in

                switch phase {
                case .empty, .failure:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                @unknown default:
                    ProgressView()
                }

            }
           )
            .frame(width: 60, height: 60)

            StagesIndicatorView(
                stages: artistSets.compactMap {
                    stages[id: $0.stageID]
                }
            )
            .frame(width: 5)

            Text(artist.name)

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
