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

public struct ExploreView: View {
    let store: Store<ExploreState, ExploreAction>

    public init(store: Store<ExploreState, ExploreAction>) {
        self.store = store
    }

    var angle: Angle = .degrees(0)
    var height: CGFloat = 275

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ExploreViewHosting(
                    artists: viewStore.artists,
                    stages: viewStore.stages,
                    schedule: viewStore.schedule
                )
            }
            .ignoresSafeArea()
        }
    }


}


struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ExploreView(
                store: .init(
                    initialState: .init(artists: Artist.testValues.asIdentifedArray, stages: Stage.testValues.asIdentifedArray, schedule: [:]),
                    reducer: exploreReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
