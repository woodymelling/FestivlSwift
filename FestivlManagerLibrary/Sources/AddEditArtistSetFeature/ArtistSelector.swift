//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/30/22.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Models


struct ArtistSelector: View {
    var artists: IdentifiedArrayOf<Artist>
    @Binding var selectedArtist: Artist?

    var body: some View {
        Picker("Artist", selection: $selectedArtist, content: {
            ForEach(artists) { artist in
                Text(artist.name).tag(artist as Artist?)
            }
        })
    }
}
