//
//  StageDetailView.swift
//
//
//  Created by Woody on 3/23/2022.
//

import SwiftUI
import ComposableArchitecture
import Components

public struct StageDetailView: View {
    let store: Store<StageDetailState, StageDetailAction>

    public init(store: Store<StageDetailState, StageDetailAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        StageIconView(
                            stage: viewStore.stage
                        )
                        .frame(square: 200)

                        Text(viewStore.stage.name)
                            .font(.largeTitle)
                    }
                }
            }
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        viewStore.send(.editStage)
                    }, label: {
                        Label("Edit", systemImage: "pencil")
                    })

                    Button(role: .destructive, action: {
                        viewStore.send(.deleteButtonPressed)
                    }, label: {
                        Label("Delete", systemImage: "trash")
                    })
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete \(viewStore.stage.name)?",
                isPresented: viewStore.binding(\.$isPresentingDeleteConfirmation),
                actions: {
                    Button("Cancel", role: .cancel) {
                        viewStore.send(.deleteConfirmationCancelled)
                    }

                    Button("Delete", role: .destructive) {
                        viewStore.send(.deleteStage)
                    }
                }
            )
            .onAppear {
                viewStore.send(.subscribeToStage)
            }
        }
    }
}

struct StageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            StageDetailView(
                store: .init(
                    initialState: .init(
                        stage: .testData,
                        event: .testData, isPresentingDeleteConfirmation: false
                    ),
                    reducer: stageDetailReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
