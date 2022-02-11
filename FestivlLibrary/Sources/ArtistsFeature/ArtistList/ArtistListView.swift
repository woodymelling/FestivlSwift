//
//  ArtistList.swift
//
//
//  Created by Woody on 2/9/2022.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct ArtistListView: View {
    let store: Store<ArtistListState, ArtistListAction>

    public init(store: Store<ArtistListState, ArtistListAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                let filteredArtists = viewStore.artists.filterForSearchTerm(viewStore.searchText)

                let indexed = filteredArtists.indexed
                List {
                    ForEach(indexed.keys.sorted(), id: \.self) { key in
                        Section(key) {
                            ForEach(indexed[key]!, id: \.self) { artist in
                                ArtistRow(artist: artist)
                            }
                        }
                    }
                }
                .searchable(text: viewStore.binding(\.$searchText))
                .listStyle(.plain)
                .navigationTitle("Artists")
            }
        }
    }
}

extension Collection where Element == Artist {
    var indexed: [String: [Artist]] {
        var dict: [String: [Artist]] = .init()

        _ = self.map { artist in
            let key = artist.name.first!.isLetter ? String(artist.name.first!) : "123"

            if dict[key] == nil {
                dict[key] = []
            }

            dict[key]!.append(artist)
        }

        return dict
    }
}

struct ArtistListView_Previews: PreviewProvider {
    static var previews: some View {

        let names = [
            "Rhythmbox",
            "Abstrakt Sonance",
            "Anti Up",
            "Bonobo",
            "Chuurch",
            "Doc Martin"

        ]

        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ArtistListView(
                store: .init(
                    initialState: .init(artists: names.map {
                        Artist(
                            id: UUID().uuidString,
                            name: $0,
                            imageURL: URL(string: "https://i1.sndcdn.com/avatars-SknftjiekzKlQO2q-DkmFhQ-t500x500.jpg")!
                        )
                    }),
                    reducer: artistListReducer,
                    environment: .init()
                )
            )
                .preferredColorScheme($0)
        }

    }
}
