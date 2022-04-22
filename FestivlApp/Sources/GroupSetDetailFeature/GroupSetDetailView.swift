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
    let store: Store<GroupSetDetailState, GroupSetDetailAction>

    public init(store: Store<GroupSetDetailState, GroupSetDetailAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {


                List {
                    Section {
                        Button(action: {
                            viewStore.send(.didTapScheduleItem(viewStore.groupSet))
                        }, label: {
                            SetView(set: viewStore.groupSet.asScheduleItem(), stages: viewStore.stages)
                        })

                    }

                    if case .groupSet = viewStore.groupSet.type {
                        Section("Artists") {
                            ForEachStore(
                                self.store.scope(
                                    state: \.artistDetailStates,
                                    action: GroupSetDetailAction.artistDetailAction
                                )
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
                                            isFavorite: artistViewStore.isFavorite
                                        )
                                    })
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle(viewStore.groupSet.title)
            }
        }
    }
}

struct GroupSetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            NavigationView {
                GroupSetDetailView(
                    store: .init(
                        initialState: .init(
                            groupSet: ScheduleItem(GroupSet(
                                name: "Test Group Set",
                                artists: Artist.testValues,
                                stageID: Stage.testData.id!,
                                startTime: Date(),
                                endTime: Date() + 1.hours
                            )),
                            event: .testData,
                            schedule: .init(),
                            artists: Artist.testValues.asIdentifedArray,
                            stages: Stage.testValues.asIdentifedArray,
                            favoriteArtists: .init()
                        ),
                        reducer: groupSetDetailReducer,
                        environment: .init()
                    )
                )
            }
            

            .preferredColorScheme($0)
        }
    }
}
