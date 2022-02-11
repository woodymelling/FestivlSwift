//
//  ArtistRow.swift
//  
//
//  Created by Woody on 2/9/22.
//

import SwiftUI
import Models
import Utilities

struct ArtistRow: View {
    @State var artist: Artist

    var body: some View {
        HStack(spacing: 10) {
            AsyncImage(url: artist.imageURL, content: { phase in

                switch phase {
                case .empty, .failure:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                @unknown default:
                    ProgressView()
                }

            }
           )
            .frame(width: 60, height: 60)

            Rectangle()
                .fill(Color.red)
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
                        ArtistRow(artist: Artist.testData)
                    }

                }
            }
            .listStyle(.plain)
            .navigationTitle("Artists")

        }
        .previewAllColorModes()

    }
}
