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
import Utilities

extension Artist: Searchable {
    public var searchTerms: [String] {
        [name]
    }
}

struct ScheduleArtistList: View {

    var store: Store<ManagerScheduleState, ManagerScheduleAction>


    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                TextField("Search...", text: viewStore.binding(\.$artistSearchText))
                    .textFieldStyle(.roundedBorder)

                ForEach(viewStore.artists.filterForSearchTerm(viewStore.artistSearchText)) { artist in
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
}

