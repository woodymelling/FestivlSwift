//
//  StagesView.swift
//
//
//  Created by Woody on 3/22/2022.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct StagesView: View {
    let store: Store<StagesState, StagesAction>

    public init(store: Store<StagesState, StagesAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.stages.isEmpty {
                Text("No Stages")
            } else {
                List {
                    ForEach(viewStore.stages) { stage in
                        NavigationLink(
                            tag: stage,
                            selection: viewStore.binding(\.$selectedStage),
                            destination: {
                                Text(stage.name)
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

                }, label: {
                    Label("Add", systemImage: "plus")
                })
            }
        }
    }
}

struct StageListRow: View {
    var stage: Stage
    var body: some View {
        HStack {
            StageIconView(stage: stage)
                .frame(square: 30)
            Text(stage.name)
                .font(.title2)
                .lineLimit(1)

            Spacer()

            Image(systemName: "chevron.right")
        }
        .padding(.horizontal)
    }
}

struct StageIconView: View {

    var stage: Stage

    var body: some View {
        GeometryReader { geo in
            AsyncImage(url: stage.iconImageURL, content: { image in
                image.resizable()
            }, placeholder: {
                Text(stage.symbol)
                    .font(.system(size: 500, weight: .bold))
                    .minimumScaleFactor(0.001)
                    .padding(2)
            })
            .frame(square: geo.size.minSideLength)
            .background(LinearGradient(colors: [stage.color, .primary], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(Circle())
        }


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
                        selectedStage: nil
                    ),
                    reducer: stagesReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
