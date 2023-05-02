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
import FestivlDependencies

public struct ArtistListView: View {
    let store: StoreOf<ArtistListFeature>
    
    public init(store: StoreOf<ArtistListFeature>) {
        self.store = store
    }
    
    
    struct ViewState: Equatable {
        enum LoadingState: Equatable {
            case loading
            case loaded(Schedule, Event, IdentifiedArrayOf<Stage>, [Artist], UserFavorites)
        }
        
        var loadingState: LoadingState
        var searchText: String
        var showArtistImages: Bool
        
        init(_ state: ArtistListFeature.State){
            self.searchText = state.searchText
            self.showArtistImages = state.showArtistImages
            
            if !state.isLoading,
               let schedule = state.schedule,
               let event = state.event,
               let stages = state.stages
            {
                self.loadingState = .loaded(schedule, event, stages, state.filteredArtists, state.userFavorites)
            } else {
                self.loadingState = .loading
            }
        }
    }
    
    
    
    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in

            Group {
                switch viewStore.loadingState {
                case .loading:
                    ProgressView()
                                        
                case let .loaded(schedule, event, stages, artists, userFavorites):
                    if artists.isEmpty {
                        NoResultsView(searchText: viewStore.searchText)
                    } else {
                        List(artists) { artist in
                            NavigationLinkStore(
                                self.store.scope(
                                    state: \.$destination,
                                    action: ArtistListFeature.Action.destination
                                ),
                                state: /ArtistListFeature.Destination.State.artistDetail,
                                action: ArtistListFeature.Destination.Action.artistDetail,
                                id: artist.id,
                                onTap: { viewStore.send(.didTapArtist(artist.id)) },
                                destination: ArtistPageView.init
                            ) {
                                ArtistRow(
                                    artist: artist,
                                    event: event,
                                    stages: stages,
                                    sets: schedule[artistID: artist.id],
                                    isFavorite: userFavorites.contains(artist.id),
                                    showArtistImage: viewStore.showArtistImages
                                )
                            }
                        }
                        .listStyle(.plain)
                 
                    }
                }
            }
            .searchable(
                text: viewStore.binding(
                    get: { $0.searchText },
                    send: { .binding(.set(\.$searchText, $0)) }
                )
            )
            .autocorrectionDisabled(true)
            .task { viewStore.send(.task) }
            .navigationTitle("Artists")

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
