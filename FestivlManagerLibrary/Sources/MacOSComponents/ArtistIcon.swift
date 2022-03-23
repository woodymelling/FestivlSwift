//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 3/20/22.
//

import SwiftUI
import Models

public struct ArtistIcon: View {

    public init(artist: Artist) {
        self.artist = artist
    }

    var artist: Artist
    public var body: some View {
        AsyncImage(url: artist.imageURL) { image in
            image
                .resizable()
        } placeholder: {
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistIcon(artist: .testData)
    }
}
