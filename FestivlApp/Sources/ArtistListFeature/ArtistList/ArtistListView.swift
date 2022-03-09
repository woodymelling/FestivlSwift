//
//  ArtistList.swift
//
//
//  Created by Woody on 2/9/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import Services
import ArtistPageFeature

public struct ArtistListView: View {
    let store: Store<ArtistListState, ArtistListAction>

    public init(store: Store<ArtistListState, ArtistListAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {

                Group {
                    if viewStore.artistStates.isEmpty {
                        ProgressView()
                    } else {

                        List {
                            ForEachStore(
                                self.store.scope(state: \.artistStates, action: ArtistListAction.artistDetail)
                            ) { artistStore in
                                WithViewStore(artistStore) { artistViewStore in
                                    NavigationLink(destination: {
                                        ArtistPageView(store: artistStore)
                                    }, label: {
                                        ArtistRow(
                                            artist: artistViewStore.artist,
                                            event: artistViewStore.event,
                                            stages: artistViewStore.stages,
                                            artistSets: artistViewStore.sets
                                        )
                                    })
                                }
                            }
                        }
                        .searchable(text: viewStore.binding(\.$searchText))
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("Artists")
            }
        }
    }
}

//extension Collection where Element == ArtistListState {
//    var indexed: [String: [Artist]] {
//        var dict: [String: [Artist]] = .init()
//
//
//        _ = self.map { artist in
//            let key = artist.name.first!.isLetter ? String(artist.name.capitalized.first!) : "123"
//
//            if dict[key] == nil {
//                dict[key] = []
//            }
//
//            dict[key]!.append(artist)
//        }
//
//        return dict
//    }
//}

struct ArtistListView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistListView(
            store: .init(
                initialState: ArtistListState(
                    event: .testData,
                    artists: [],
                    stages: [],
                    artistSets: [],
                    searchText: ""
                ),
                reducer: artistListReducer,
                environment: .init()
            )
        )
            .previewAllColorModes()

    }
}
