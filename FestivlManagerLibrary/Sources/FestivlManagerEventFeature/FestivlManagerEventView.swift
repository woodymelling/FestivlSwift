//
//  FestivlManagerEvent.swift
//
//
//  Created by Woody on 3/8/2022.
//

import SwiftUI
import ComposableArchitecture

public struct FestivlManagerEventView: View {
    let store: Store<FestivlManagerEventState, FestivlManagerEventAction>

    public init(store: Store<FestivlManagerEventState, FestivlManagerEventAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct FestivlManagerEventView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            FestivlManagerEventView(
                store: .init(
                    initialState: .init(),
                    reducer: festivlManagerEventReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
