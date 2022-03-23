//
//  ManagerArtistDetailView.swift
//
//
//  Created by Woody on 3/20/2022.
//

import SwiftUI
import ComposableArchitecture
import MacOSComponents
import Services
import SharedResources

public struct ManagerArtistDetailView: View {
    let store: Store<ManagerArtistDetailState, ManagerArtistDetailAction>

    public init(store: Store<ManagerArtistDetailState, ManagerArtistDetailAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        ArtistIcon(artist: viewStore.artist)
                            .frame(square: 200)

                        Text(viewStore.artist.name)
                            .font(.largeTitle)
                    }

                    if let description = viewStore.artist.description {
                        HStack {
                            Text("Description: ")
                            Text(description)
                                .font(.body)
                                .lineLimit(nil)
                        }
                    }

                    if let tier = viewStore.artist.tier {
                        Text("Explore Tier: \(tier)")
                    }

                    LinksView(store: store)

                }
                .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        viewStore.send(.editArtist)
                    }, label: {
                        Label("Edit", systemImage: "pencil")
                    })
                }
            }
        }
    }
}

extension String {
    var asURL: URL? {
        return URL(string: self)
    }
}

struct LinksView: View {
    let store: Store<ManagerArtistDetailState, ManagerArtistDetailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                if let soundcloudURL = viewStore.artist.soundcloudURL?.asURL {
                    LinkButton(
                        url: soundcloudURL,
                        icon: SharedResources.LinkIcons.spotify
                    ) { url in
                        viewStore.send(.navigateToURL(soundcloudURL))
                    }
                }

                if let spotifyURL = viewStore.artist.spotifyURL?.asURL {
                    LinkButton(
                        url: spotifyURL,
                        icon: SharedResources.LinkIcons.spotify
                    ) { url in
                        viewStore.send(.navigateToURL(spotifyURL))
                    }
                }

                if let websiteURL = viewStore.artist.websiteURL?.asURL {
                    LinkButton(url: websiteURL, icon: SharedResources.LinkIcons.website) { url in
                        viewStore.send(.navigateToURL(websiteURL))
                    }
                }
            }
        }
    }
}


struct ManagerArtistDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ManagerArtistDetailView(
                store: .init(
                    initialState: .init(artist: .testData, event: .testData),
                    reducer: managerArtistDetailReducer,
                    environment: .init(artistService: { ArtistMockService() })
                )
            )
            .preferredColorScheme($0)
        }
    }
}
