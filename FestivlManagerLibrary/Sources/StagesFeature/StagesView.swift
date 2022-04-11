//
//  StagesView.swift
//
//
//  Created by Woody on 3/22/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import AddEditStageFeature
import StageDetailFeature
import Components

public struct StagesView: View {
    let store: Store<StagesState, StagesAction>

    public init(store: Store<StagesState, StagesAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                if viewStore.stages.isEmpty {
                    Text("No Stages")
                } else {
                    List {
                        ForEach(viewStore.stages) { stage in
                            NavigationLink(
                                tag: stage,
                                selection: viewStore.binding(\.$selectedStage),
                                destination: {
                                    IfLetStore(
                                        store.scope(
                                            state: \.stageDetailState,
                                            action: StagesAction.stageDetailAction
                                        ),
                                        then: StageDetailView.init
                                    )
                                },
                                label: { StageListRow(stage: stage) }
                            )
                        }
                        .onMove { indices, newOffset in
                            viewStore.send(.stagesReordered(fromOffsets: indices, toOffset: newOffset))
                        }
                    }

                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        viewStore.send(.addStageButtonPressed)
                    }, label: {
                        Label("Add Stage", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    })
                }
            }
            .sheet(item: viewStore.binding(\StagesState.$addEditStageState)) { _ in
                IfLetStore(
                    store.scope(
                        state: \.addEditStageState,
                        action: StagesAction.addEditStageAction
                    ),
                    then: AddEditStageView.init
                )
            }


       }

    }
}

struct StageListRow: View {
    var stage: Stage
    var body: some View {
        HStack {
            StageIconView(stage: stage)
                .frame(square: 60)
            Text(stage.name)
                .font(.title2)
                .lineLimit(1)

            Spacer()

            Image(systemName: "chevron.right")
        }
        .padding(.horizontal)
    }
}

struct StagesView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            StagesView(
                store: .init(
                    initialState: .init(
                        stages: Stage.testValues.asIdentifedArray,
                        event: .testData,
                        selectedStage: nil,
                        addEditStageState: nil, isPresentingDeleteConfirmation: false
                    ),
                    reducer: stagesReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
