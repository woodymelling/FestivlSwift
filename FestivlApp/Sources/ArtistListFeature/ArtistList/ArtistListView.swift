//
//  ArtistList.swift
//
//
//  Created by Woody on 2/9/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import ArtistPageFeature
import Components
import iOSComponents

public struct ArtistListView: View {
    let store: StoreOf<ArtistListFeature>
    
    public init(store: StoreOf<ArtistListFeature>) {
        self.store = store
    }
    
    
    struct ViewState: Equatable {
        var schedule: Schedule?
        var event: Event?
        var states: IdentifiedArrayOf<Stage>
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Group {
                
                    if !viewStore.isLoading,
                       let schedule = viewStore.schedule,
                       let event = viewStore.event,
                       let stages = viewStore.stages {
                        
                        if viewStore.filteredArtistStates.isEmpty {
                            NoResultsView(searchText: viewStore.searchText)
                        } else {
                            List {
                                ForEachStore(
                                    store.scope(
                                        state: \.filteredArtistStates,
                                        action: ArtistListFeature.Action.artistDetail
                                    )
                                ) { artistStore in
                                    NavigationLink {
                                        ArtistPageView(store: artistStore)
                                    } label: {
                                        
                                        WithViewStore(artistStore) { artistViewStore in
                                            
                                            if let artist = artistViewStore.artist {
                                                ArtistRow(
                                                    artist: artist,
                                                    event: event,
                                                    stages: stages,
                                                    sets: schedule[artistID: artist.id],
                                                    isFavorite: artistViewStore.isFavorite,
                                                    showArtistImage: viewStore.showArtistImages
                                                )
                                            }
                                            
                                        }
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .searchable(text: viewStore.binding(\.$searchText))
                        }
                    } else {
                        ProgressView()
                        Text("Loading")
                    }
                }
                .task {
                    viewStore.send(.task)
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
                initialState: .init(),
                reducer: ArtistListFeature()
            )
        )
        .previewAllColorModes()
        
    }
}
