//
//  StagesView.swift
//
//
//  Created by Woody on 3/22/2022.
//

import SwiftUI
import ComposableArchitecture

public struct StagesView: View {
    let store: Store<StagesState, StagesAction>

    public init(store: Store<StagesState, StagesAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct StagesView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            StagesView(
                store: .init(
                    initialState: .init(),
                    reducer: stagesReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}