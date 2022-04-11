//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/9/22.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct BulkAddView: View {

    let store: Store<BulkAddState, BulkAddAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Text("Bulk Add Artists")
                    .font(.largeTitle)

                TextField("Seperator", text: viewStore.binding(\.$seperator))
                Toggle("Adjust Capitalization", isOn: viewStore.binding(\.$shouldAdjustCapitalization))

                TextEditor(text: viewStore.binding(\.$text))
                    .frame(width: 200, height: 400)

                if viewStore.loading {
                    ProgressView()
                } else {
                    HStack {
                        Button("Save") {
                            viewStore.send(.saveButtonPressed)
                        }

                        Button("Cancel") {
                            viewStore.send(.cancelButtonPressed)
                        }
                    }
                }

            }
            .padding()

        }

    }
}
