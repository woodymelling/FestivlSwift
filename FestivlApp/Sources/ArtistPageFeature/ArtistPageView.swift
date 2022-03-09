//
//  ArtistPage.swift
//
//
//  Created by Woody on 2/13/2022.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct ArtistPageView: View {
    let store: Store<ArtistPageState, ArtistPageAction>

    public init(store: Store<ArtistPageState, ArtistPageAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in

            VStack {
                ArtistHeaderView(artist: viewStore.artist, event: viewStore.event)

                List {
                    ForEach(viewStore.sets) { artistSet in
                        ArtistSetView(
                            set: artistSet,
                            stages: viewStore.stages
                        )
                    }

                    if let description = viewStore.artist.description {
                        Text(description)

                    }

                    if viewStore.artist.soundcloudURL != nil {
                        ArtistLinkView(linkType: .soundcloud)
                    }

                    if viewStore.artist.spotifyURL != nil {
                        ArtistLinkView(linkType: .spotify)
                    }

                    if viewStore.artist.websiteURL != nil {
                        ArtistLinkView(linkType: .website)
                    }
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                    Button(action: {

                    }, label: {
                        Image(systemName: "heart")
                    })
                })
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct ArtistPageView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            NavigationView {
                ArtistPageView(
                    store: .init(
                        initialState: .init(artist: Artist.testValues[1], event: .testData, sets: [.testData], stages: IdentifiedArrayOf(uniqueElements: [.testData])),
                        reducer: artistPageReducer,
                        environment: .init()
                    )
                )
                
            }
            .preferredColorScheme($0)
        }
    }
}
