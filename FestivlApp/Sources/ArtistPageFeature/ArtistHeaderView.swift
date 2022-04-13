//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/13/22.
//

import SwiftUI
import Models
import Utilities

struct ArtistHeaderView: View {
    var artist: Artist
    var event: Event

    var initialHeight = UIScreen.main.bounds.height / 3

    var body: some View {
        ZStack(alignment: .bottom) {

            CachedAsyncImage(url: artist.imageURL ?? event.imageURL, placeholder: {
                ProgressView()
            })
            .frame(height: initialHeight)
            .aspectRatio(contentMode: .fill)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemBackground),
                        .clear
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .overlay(alignment: .bottomLeading) {
                Text(artist.name)
                    .font(.system(size: 30))
                    .padding()
            }
        }
        .frame(height: initialHeight)
    }
}


struct ArtistHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistHeaderView(artist: Artist.testValues[1], event: .testData)
    }
}
