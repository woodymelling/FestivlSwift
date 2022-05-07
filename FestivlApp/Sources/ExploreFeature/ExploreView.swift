//
//  Explore.swift
//
//
//  Created by Woody on 3/2/2022.
//

import SwiftUI
import ComposableArchitecture
import Utilities
import Models
import ArtistPageFeature

public struct ExploreView: View {
    let store: Store<ExploreState, ExploreAction>

    public init(store: Store<ExploreState, ExploreAction>) {
        self.store = store
    }

    var angle: Angle = .degrees(0)
    var height: CGFloat = 275

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    NavigationLink(isActive: viewStore.binding(\.$selectedArtistPageState).isPresent(), destination: {
                        IfLetStore(store.scope(state: \.selectedArtistPageState, action: {
                            ExploreAction.artistPage(id: viewStore.selectedArtistPageState?.id, action: $0)
                        }), then: ArtistPageView.init)
                    }, label: { EmptyView() })

                    ExploreViewHosting(
                        artists: viewStore.artistStates,
                        stages: viewStore.stages,
                        schedule: viewStore.schedule,
                        onSelectArtist: {
                            viewStore.send(.didSelectArtist($0.artist))
                        },
                        favoriteArtists: viewStore.favoriteArtists
                    )
                    .navigationBarHidden(true)
                    .ignoresSafeArea(SafeAreaRegions.all, edges: .all)
                }
            }
        }
    }


}

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


struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ExploreView(
                store: .init(
                    initialState: .init(artists: Artist.testValues.asIdentifedArray, event: .testData, stages: Stage.testValues.asIdentifedArray, schedule: [:], selectedArtistPageState: nil, favoriteArtists: .init()),
                    reducer: exploreReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
