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
    let store: StoreOf<ExploreFeature>
    
    public init(store: StoreOf<ExploreFeature>) {
        self.store = store
    }
    
    var angle: Angle = .degrees(0)
    var height: CGFloat = 275
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            ZStack {
                NavigationLink(isActive: viewStore.binding(\.$selectedArtistPageState).isPresent()) {
                    IfLetStore(
                        store.scope(
                            state: \.selectedArtistPageState,
                            action: { .artistDetail(id: viewStore.selectedArtistPageState!.id, action: $0)
                            }
                        ),
                        then: ArtistPageView.init
                    )
                } label: { EmptyView() }
                
                if !viewStore.isLoading,
                   let stages = viewStore.stages,
                   let schedule = viewStore.schedule {
                    
                    ExploreViewHosting(
                        artists: viewStore.artistStates,
                        stages: stages,
                        schedule: schedule,
                        onSelectArtist: {
                            viewStore.send(.didTapArtist($0))
                        }
                    )
                    .navigationBarHidden(true)
                } else {
                    ProgressView()
                }
                
            }
            .ignoresSafeArea(SafeAreaRegions.all, edges: .all)
            .task {
                await viewStore.send(.task).finish()
            }
        }
        
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ExploreView(
                store: .init(
                    initialState: .init(),
                    reducer: ExploreFeature()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
