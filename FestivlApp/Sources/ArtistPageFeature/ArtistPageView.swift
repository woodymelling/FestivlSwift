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
import iOSComponents


public struct ArtistPageView: View {
    let store: StoreOf<ArtistDetail>

    public init(store: StoreOf<ArtistDetail>) {
        self.store = store
    }

    // TODO: Move to Reducer when doing navigation updates
    @State var navigatingURL: URL?

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if let artist = viewStore.artist,
                   let schedule = viewStore.schedule {
                    VStack {
                        DetailsHeaderView(imageURL: artist.imageURL) {
                            Text(artist.name)
                                .font(.system(size: 30))
                                .padding()
                        }
                        
                        List {
                            ForEach(
                                schedule[artistID: viewStore.artistID].sorted(by: \.startTime)
                            ) { scheduleItem in
                                Button {
                                    viewStore.send(.didTapScheduleItem(scheduleItem))
                                } label: {
                                    SetView(set: scheduleItem)
                                }
                            }
                            
                            if let description = artist.description, !description.isEmpty {
                                Text(description)
                            }
                            
                 
                            // MARK: Socials
                            if let urlString = artist.spotifyURL, let url = URL(string: urlString), !(artist.soundcloudURL?.isEmpty ?? true) {
                                ArtistLinkView(linkType: .spotify) {
                                    navigatingURL = url
                                }
                            }
                            
                            if let urlString = artist.soundcloudURL, let url = URL(string: urlString), !(artist.soundcloudURL?.isEmpty ?? true) {
                                ArtistLinkView(linkType: .soundcloud) {
                                    navigatingURL = url
                                }
                            }
                            
                            
                            if let urlString = artist.websiteURL, let url = URL(string: urlString), !(artist.websiteURL?.isEmpty ?? true) {
                                ArtistLinkView(linkType: .website) {
                                    navigatingURL = url
                                }
                            }
                            
                            if let urlString = artist.instagramURL.map({ URL(string: $0) }), !(artist.instagramURL?.isEmpty ?? true) {
                                ArtistLinkView(linkType: .instagram) {
                                    navigatingURL = urlString
                                }
                            }
      
                            if let urlString = artist.facebookURL.map({ URL(string: $0) }), !(artist.facebookURL?.isEmpty ?? true) {
                                ArtistLinkView(linkType: .facebook) {
                                    navigatingURL = urlString
                                }
                            }
                            
                            if let urlString = artist.youtubeURL.map({ URL(string: $0) }), !(artist.youtubeURL?.isEmpty ?? true) {
                                ArtistLinkView(linkType: .youtube) {
                                    navigatingURL = urlString
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
    func toolbar(viewStore: ViewStore<ArtistDetail.State, ArtistDetail.Action>) -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction, content: {
            Button(action: {
                viewStore.send(ArtistDetail.Action.favoriteArtistButtonTapped)
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
                initialState: .init(artistID: Artist.testValues.first!.id, isFavorite: false),
                reducer: ArtistDetail()
            )
        )
    }
}


