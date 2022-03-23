//
//  ManagerArtistsView.swift
//
//
//  Created by Woody on 3/10/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import CreateArtistFeature
import MacOSComponents
import ManagerArtistDetailFeature

public struct ManagerArtistsView: View {
    let store: Store<ManagerArtistsState, ManagerArtistsAction>

    public init(store: Store<ManagerArtistsState, ManagerArtistsAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Spacer()
                    .frame(height: 20)
                
                ForEach(viewStore.artists) { artist in
                    NavigationLink(
                        tag: artist,
                        selection: viewStore.binding(\.$selectedArtist),
                        destination: {
                            IfLetStore(
                                store.scope(
                                    state: \.artistDetailState,
                                    action: ManagerArtistsAction.artistDetailAction
                                ),
                                then: ManagerArtistDetailView.init
                            )
                        },
                        label: { ArtistRow(artist: artist) }
                    )
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        viewStore.send(.addArtistButtonPressed)
                    }, label: {
                        Label("Add Artist", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    })
                }
            }
            .sheet(item: viewStore.binding(\ManagerArtistsState.$createArtistState)) { _ in

                IfLetStore(
                    store.scope(
                        state: \.createArtistState,
                        action: ManagerArtistsAction.createArtistAction
                    ),
                    then: CreateArtistView.init
                )
            }
        }
    }
}

struct ArtistRow: View {
    let artist: Artist

    var body: some View {
        HStack {
            ArtistIcon(artist: artist)
                .frame(square: 50)
            Text(artist.name)
        }
    }
}

struct ManagerArtistsView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            NavigationView {
                ManagerArtistsView(
                    store: .init(
                        initialState: .init(
                            artists: Artist.testValues.asIdentifedArray,
                            selectedArtist: nil,
                            event: .testData,
                            createArtistState: nil
                        ),
                        reducer: managerArtistsReducer,
                        environment: .init()
                    )
                )
            }

            .preferredColorScheme($0)
        }
    }
}
