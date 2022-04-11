//
//  AddEditEventView.swift
//
//
//  Created by Woody on 4/8/2022.
//

import SwiftUI
import ComposableArchitecture
import MacOSComponents

public struct AddEditEventView: View {
    let store: Store<AddEditEventState, AddEditEventAction>

    public init(store: Store<AddEditEventState, AddEditEventAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Create Event")
                    .font(.largeTitle)
                Form {
                    TextField(
                        "Event Name",
                        text: viewStore.binding(\.$name)
                    )

                    DatePicker(
                        "Start Date",
                        selection: viewStore.binding(\.$startDate),
                        in: Date()...(.distantFuture),
                        displayedComponents: [.date]
                    )

                    DatePicker(
                        "End Date",
                        selection: viewStore.binding(\.$endDate),
                        in: viewStore.startDate...(.distantFuture),
                        displayedComponents: [.date]
                    )

                    Toggle(
                        "Day starts at noon",
                        isOn: viewStore.binding(\.$dayStartsAtNoon)
                    )
                }

                ImagePicker(outputImage: viewStore.binding(\.$image), selectedImage: viewStore.binding(\.$selectedImage))

                HStack {
                    Button("Save") {
                        viewStore.send(.saveButtonPressed)
                    }
                    Button("Cancel", role: .cancel, action: {
                        viewStore.send(.cancelButtonPressed)
                    })
                }
            }
            .padding(.horizontal)
            .navigationTitle("Create New Event")
        }
    }
}

struct AddEditEventView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            AddEditEventView(
                store: .init(
                    initialState: .init(),
                    reducer: addEditEventReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
