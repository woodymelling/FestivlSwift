//
//  AddEditStageView.swift
//
//
//  Created by Woody on 3/22/2022.
//

import SwiftUI
import ComposableArchitecture
import Components
import MacOSComponents
import Models

public struct AddEditStageView: View {
    let store: Store<AddEditStageState, AddEditStageAction>

    public init(store: Store<AddEditStageState, AddEditStageAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                List {
                    Text(viewStore.mode.viewTitle)
                        .font(.largeTitle)

                    Form {
                        TextField("Name", text: viewStore.binding(\.$name), prompt: Text("(Required)"))

                        TextField("Symbol", text: viewStore.binding(\.$symbol))
                            .frame(width: 100)

                        ColorPicker("Color", selection: viewStore.binding(\.$color))

                        VStack {
                            ImagePicker(outputImage: viewStore.binding(\.$image), selectedImage: viewStore.binding(\.$selectedImage))
                        }
                    }
                }

                Spacer()

                HStack {
                    Button(viewStore.mode.saveButtonName) {
                        viewStore.send(.saveButtonPressed)
                    }

                    Button("Cancel") {
                        viewStore.send(.cancelButtonPressed)
                    }
                }
                .padding()

            }
            .frame(minWidth: 500, minHeight: 600)
            .onAppear { viewStore.send(.loadImageIfRequired) }
            .loading(viewStore.loading)
        }
    }
}

struct AddEditStageView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            AddEditStageView(
                store: .init(
                    initialState: .init(
                        eventID: Event.testData.id!,
                        stageCount: 0
                    ),
                    reducer: addEditStageReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
