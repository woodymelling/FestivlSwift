//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/13/22.
//

import SwiftUI
import Models
import Utilities
import Components

struct ArtistHeaderView: View {
    var artist: Artist
    var event: Event

    var initialHeight = UIScreen.main.bounds.height / 2.5

    var body: some View {
        ZStack(alignment: .bottom) {
            
            Group {
                if let artistImageURL = artist.imageURL {
                    CachedAsyncImage(url: artistImageURL) { ProgressView() }
                        .aspectRatio(contentMode: .fill)
                } else {
                    CachedAsyncImage(url: event.imageURL, renderingMode: .template) {
                        ProgressView()
                    }
                }
            }
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
