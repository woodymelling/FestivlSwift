//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/31/22.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Models
import MacOSComponents

struct ScheduleArtistList: View {

    var artists: IdentifiedArrayOf<Artist>


    var body: some View {
        List {
            ForEach(artists) { artist in
                HStack {
                    ArtistIcon(artist: artist)
                        .frame(square: 50)
                    Text(artist.name)
                }
                .onDrag {
                    artist.itemProvider
                }
            }
        }
        .frame(width: 150)
    }
}

