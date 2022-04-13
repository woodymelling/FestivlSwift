//
//  Schedule.swift
//
//
//  Created by Woody on 2/17/2022.
//

import SwiftUI
import ComposableArchitecture
import Utilities
import Models
import SimultaneouslyScrollView

public struct SingleStageAtOnceView: View {
    let store: Store<ScheduleState, ScheduleAction>

    @StateObject var scrollViewModel: ViewModel = .init()

    public init(store: Store<ScheduleState, ScheduleAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in

            VStack(spacing: 0) {
                ScheduleHeaderView(stages: viewStore.stages, selectedStage: viewStore.binding(\.$selectedStage).animation(.easeInOut(duration: 0.1)))
                    .padding(.bottom)

                TabView(selection: viewStore.binding(\.$selectedStage).animation(.easeInOut(duration: 0.1))) {
                    ForEach(viewStore.stages) { stage in
                        ScheduleScrollView(store: store, style: .singleStage(stage), scrollViewHandler: scrollViewModel)
                            .tag(stage)
                    }

                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

        }
    }

    class ViewModel: ObservableObject {
        var scrollViewHandler = SimultaneouslyScrollViewHandlerFactory.create()

        init() {}
    }
}

struct SingleStageAtOnceView_Previews: PreviewProvider {
    static var previews: some View {
        SingleStageAtOnceView(
            store: .init(
                initialState: .init(
                    stages: Stage.testValues.asIdentifedArray,
                    artistSets: ArtistSet.testValues().asIdentifedArray,
                    groupSets: .init(),
                    selectedStage: Stage.testValues[0],
                    event: .testData,
                    selectedDate: Event.testData.festivalDates[0]
                ),
                reducer: scheduleReducer,
                environment: .init()
            )
        )
        .previewAllColorModes()
//        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
    }

}
