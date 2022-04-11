//
//  AddEditGroupSetView.swift
//
//
//  Created by Woody on 4/10/2022.
//

import SwiftUI
import ComposableArchitecture

public struct AddEditGroupSetView: View {
    let store: Store<AddEditGroupSetState, AddEditGroupSetAction>

    public init(store: Store<AddEditGroupSetState, AddEditGroupSetAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct AddEditGroupSetView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            AddEditGroupSetView(
                store: .init(
                    initialState: .init(),
                    reducer: addEditGroupSetReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}