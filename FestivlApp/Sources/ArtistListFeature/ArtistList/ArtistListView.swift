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
            case loaded(Schedule, Event, [Artist], UserFavorites)
        }
        
        var loadingState: LoadingState
        @BindingViewState var searchText: String
        var showArtistImages: Bool
        
        init(_ state: BindingViewStore<ArtistListFeature.State>){
            self._searchText = state.$searchText
            self.showArtistImages = state.showArtistImages
            
            if !state.isLoading,
               let schedule = state.schedule,
               let event = state.event
            {
                self.loadingState = .loaded(schedule, event, state.filteredArtists, state.userFavorites)
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
                                        
                case let .loaded(schedule, event, artists, userFavorites):
                    if artists.isEmpty {
                        NoResultsView(searchText: viewStore.searchText)
                    } else {
                        List(artists) { artist in
                            
                            Button {
                                viewStore.send(.didTapArtist(artist.id))
                            } label: {
                                ArtistRow(
                                    artist: artist,
                                    event: event,
                                    sets: schedule[artistID: artist.id],
                                    isFavorite: userFavorites.contains(artist.id),
                                    showArtistImage: true
                                )
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .searchable(text: viewStore.$searchText)
            .autocorrectionDisabled(true)
            .task { viewStore.send(.task) }
            .navigationTitle("Artists")
            .navigationDestination(
                store: store.scope(
                    state: \.$artistDetail,
                    action: ArtistListFeature.Action.artistDetail
                ),
                destination: ArtistPageView.init
            )
        }
    }
}

struct ArtistListView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistListView(
            store: .init(
                initialState: .init(),
                reducer: ArtistListFeature.init
            )
        )        
    }
}
