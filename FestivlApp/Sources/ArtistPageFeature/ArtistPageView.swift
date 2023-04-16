//
//  ArtistPage.swift
//
//
//  Created by Woody on 2/13/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import Utilities
//import Introspect


public struct ArtistPageView: View {
    let store: StoreOf<ArtistPage>

    public init(store: StoreOf<ArtistPage>) {
        self.store = store
    }

    // TODO: Move to Reducer when doing navigation updates
    @State var navigatingURL: URL?

    public var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                if let artist = viewStore.artist,
                   let event = viewStore.event,
                   let schedule = viewStore.schedule,
                   let stages = viewStore.stages {
                    VStack {
                        ArtistHeaderView(artist: artist, event: event)
                        
                        List {
                            ForEach(
                                schedule[artistID: viewStore.artistID].sortedByStartTime
                            ) { scheduleItem in
                                Button {
                                    viewStore.send(.didTapScheduleItem(scheduleItem))
                                } label: {
                                    SetView(
                                        set: scheduleItem,
                                        stages: stages
                                    )
                                }
                            }
                            
                            if let description = artist.description, !description.isEmpty {
                                Text(description)
                            }
                            
                            if let urlString = artist.soundcloudURL, let url = URL(string: urlString) {
                                ArtistLinkView(linkType: .soundcloud) {
                                    navigatingURL = url
                                }
                            }
                            
                            if let urlString = artist.spotifyURL, let url = URL(string: urlString) {
                                ArtistLinkView(linkType: .spotify) {
                                    navigatingURL = url
                                }
                            }
                            
                            if let urlString = artist.websiteURL, let url = URL(string: urlString) {
                                ArtistLinkView(linkType: .website) {
                                    navigatingURL = url
                                }
                            }
                        }
                        .listStyle(.plain)
                        .ignoresSafeArea(.all, edges: [.leading,.trailing,.top])
                    }
                    .clipped()
                    .edgesIgnoringSafeArea(.top)
                    .toolbar(content: { toolbar(viewStore: viewStore) })
                    
                } else {
                    
                    ProgressView()
                }
            }
            .task { await viewStore.send(.task).finish() }
                
        }
        .sheet(isPresented: $navigatingURL.isPresent(), content: {
            if let navigatingURL = navigatingURL {
                SafariView(url: navigatingURL)
            } else {
                EmptyView()
            }

        })
    }

    @ToolbarContentBuilder
    func toolbar(viewStore: ViewStore<ArtistPage.State, ArtistPage.Action>) -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction, content: {
            Button(action: {
                viewStore.send(ArtistPage.Action.favoriteArtistButtonTapped)
            }, label: {
                Group {
                    if viewStore.isFavorite {
                        Label(title: {
                            Text("Unfavorite Artist")
                        }, icon: {
                            Image(systemName: "heart.fill")
                        })
                        .labelStyle(.iconOnly)
                    } else {
                        Label(title: {
                            Text("Favorite Artist")
                        }, icon: {
                            Image(systemName: "heart")
                        })
                        .labelStyle(.iconOnly)
                    }
                }

            })
        })
    }

}

import SafariServices

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariView>
    ) {}

}

struct ArtistPageView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistPageView(
            store: .init(
                initialState: .init(artistID: .init(""), isFavorite: false),
                reducer: ArtistPage()
            )
        )
    }
}
