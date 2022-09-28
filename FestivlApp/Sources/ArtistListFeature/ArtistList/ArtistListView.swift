//
//  ArtistList.swift
//
//
//  Created by Woody on 2/9/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import Services
import ArtistPageFeature
import iOSComponents

public struct ArtistListView: View {
    let store: StoreOf<ArtistListFeature>

    public init(store: StoreOf<ArtistListFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {

                Group {
                    if viewStore.artistStates.isEmpty {
                        ProgressView()
                    } else {

                        List {
                            ForEachStore(
                                self.store.scope(state: \.filteredArtistStates, action: ArtistListFeature.Action.artistDetail)
                            ) { artistStore in
                                WithViewStore(artistStore) { artistViewStore in
                                    
                                    NavigationLink(destination: {
                                        ArtistPageView(store: artistStore)
                                    }, label: {
                                        ArtistRow(
                                            artist: artistViewStore.artist,
                                            event: artistViewStore.event,
                                            stages: artistViewStore.stages,
                                            sets: artistViewStore.sets,
                                            isFavorite: artistViewStore.isFavorite,
                                            showArtistImage: viewStore.showArtistImages
                                        )
                                    })
                                }
                            }
                        }
                        .searchable(text: viewStore.binding(\.$searchText))
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("Artists")
            }
            .navigationViewStyle(.stack)
        }
    }
}

struct ArtistListView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistListView(
            store: .init(
                initialState: .init(
                    event: .testData,
                    artists: [],
                    stages: [],
                    schedule: .init(),
                    searchText: "",
                    favoriteArtists: .init(),
                    showArtistImages: true
                ),
                reducer: ArtistListFeature()
            )
        )
        .previewAllColorModes()

    }
}
