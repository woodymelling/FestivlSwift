//
//  GroupSetDetailView.swift
//
//
//  Created by Woody on 4/16/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import ArtistPageFeature
import Components
import iOSComponents
import FestivlDependencies

public struct GroupSetDetailView: View {
    let store: StoreOf<GroupSetDetail>
    
    public init(store: StoreOf<GroupSetDetail>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        enum LoadingState: Equatable {
            case loading
            case loaded(Schedule, Event, IdentifiedArrayOf<Artist>, UserFavorites)
        }
        
        var loadingState: LoadingState
        var groupSet: ScheduleItem
        var showArtistImages: Bool
        
        init(_ state: GroupSetDetail.State){
            self.showArtistImages = state.showArtistImages
            self.groupSet = state.groupSet
            
            if let schedule = state.schedule,
               let event = state.event
            {
                self.loadingState = .loaded(schedule, event, state.artists, state.userFavorites)
            } else {
                self.loadingState = .loading
            }
        }
    }
    
    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationView {
                Group {
                    switch viewStore.loadingState {
                    case .loading:
                        ProgressView()
                    case let .loaded(schedule, event, artists, userFavorites):
                        List {
                            Section {
                                Button(action: {
                                    viewStore.send(.didTapScheduleItem(viewStore.groupSet))
                                }, label: {
                                    SetView(set: viewStore.groupSet)
                                })
                            }
                            
                            Section("Artists") {
                                ForEach(artists) { artist in
                                    NavigationLinkStore(
                                        self.store.scope(
                                            state: \.$destination,
                                            action: GroupSetDetail.Action.destination
                                        ),
                                        state: /GroupSetDetail.Destination.State.artistDetail,
                                        action: GroupSetDetail.Destination.Action.artistDetail,
                                        id: artist.id,
                                        onTap: { viewStore.send(.didTapArtist(artist.id)) },
                                        destination: ArtistPageView.init
                                    ) {
                                        ArtistRow(
                                            artist: artist,
                                            event: event,
                                            sets: schedule[artistID: artist.id],
                                            isFavorite: userFavorites.contains(artist.id),
                                            showArtistImage: viewStore.showArtistImages
                                        )
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .navigationTitle(viewStore.groupSet.title)
                .task { await viewStore.send(.task).finish() }
            }
        }
    }
}
