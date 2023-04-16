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

public struct GroupSetDetailView: View {
    let store: StoreOf<GroupSetDetail>

    public init(store: StoreOf<GroupSetDetail>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    if let event = viewStore.event,
                       let schedule = viewStore.schedule {
                        Section {
                            Button(action: {
                                viewStore.send(.didTapScheduleItem(viewStore.groupSet))
                            }, label: {
                                SetView(set: viewStore.groupSet, stages: viewStore.stages)
                            })
                            
                        }
                        
                        Section("Artists") {
                            ForEachStore(
                                self.store.scope(
                                    state: \.artistDetailStates,
                                    action: GroupSetDetail.Action.artistDetailAction
                                )
                            ) { artistStore in
                                WithViewStore(artistStore) { artistViewStore in
                                    NavigationLink(destination: {
                                        ArtistPageView(store: artistStore)
                                    }, label: {
                                        ArtistRow(
                                            artist: artistViewStore.artist!,
                                            event: event,
                                            stages: viewStore.stages,
                                            sets: schedule[artistID: artistViewStore.artist!.id],
                                            isFavorite: false,
                                            showArtistImage: false
                                        )
                                    })
                                }
                            }
                        }
                        
                    }
                }
                .listStyle(.plain)
                .navigationTitle(viewStore.groupSet.title)
                .task { await viewStore.send(.task).finish() }
            }
        }
    }
}
