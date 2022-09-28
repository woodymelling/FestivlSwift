//
//  ArtistPage.swift
//
//
//  Created by Woody on 2/13/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import Introspect

public struct ArtistPageView: View {
    let store: StoreOf<ArtistPage>

    public init(store: StoreOf<ArtistPage>) {
        self.store = store
    }

    @State var navigatingURL: URL?

    public var body: some View {
        WithViewStore(store) { viewStore in

            VStack {
                ArtistHeaderView(artist: viewStore.artist, event: viewStore.event)

                List {
                    ForEach(viewStore.sets) { scheduleSet in
                        Button(action: {
                            viewStore.send(.didTapArtistSet(scheduleSet))
                        }, label: {
                            SetView(
                                set: scheduleSet,
                                stages: viewStore.stages
                            )
                        })
                    }

                    if let description = viewStore.artist.description, !description.isEmpty {
                        Text(description)
                    }

                    if let urlString = viewStore.artist.soundcloudURL, let url = URL(string: urlString) {
                        ArtistLinkView(linkType: .soundcloud) {
                            navigatingURL = url
                        }
                    }

                    if let urlString = viewStore.artist.spotifyURL, let url = URL(string: urlString) {
                        ArtistLinkView(linkType: .spotify) {
                            navigatingURL = url
                        }
                    }

                    if let urlString = viewStore.artist.websiteURL, let url = URL(string: urlString) {
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

extension Binding {
    public func isPresent<Wrapped>() -> Binding<Bool>
      where Value == Wrapped? {
        .init(
          get: {
              self.wrappedValue != nil

          },
          set: { isPresent, transaction in
            if !isPresent {
              self.transaction(transaction).wrappedValue = nil
            }
          }
        )
      }
}

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
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            NavigationView {
                ArtistPageView(
//                    store: .init(
//                        initialState: .init(artist: Artist.testValues[1], event: .testData, setsForArtist: [ArtistSet.testData.asScheduleItem()], stages: IdentifiedArrayOf(uniqueElements: [.testData]), isFavorite: false),
//                        reducer: artistPageReducer,
//                        environment: .init()
//                    )
                    
                    store: .init(
                        initialState: .init(
                            artist: Artist.testValues[1],
                            event: .testData,
                            setsForArtist: [ArtistSet.testData.asScheduleItem()],
                            stages: IdentifiedArrayOf(uniqueElements: [.testData]),
                            isFavorite: false),
                        reducer: ArtistPage()
                    )
                )
                
            }
            .preferredColorScheme($0)
        }
    }
}
