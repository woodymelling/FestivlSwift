//
//  TimelineHeaderView.swift
//
//
//  Created by Woody on 3/29/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import MacOSComponents

public struct TimelineHeaderView: View {
    let store: Store<TimelineHeaderState, TimelineHeaderAction>

    public init(store: Store<TimelineHeaderState, TimelineHeaderAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                EventDaySelector(
                    title: "Current Date",
                    selectedDate: viewStore.binding(\.$selectedDate).animation(),
                    festivalDates: viewStore.festivalDates
                )
                .frame(maxWidth: 200)
            }

            HStack {
                ForEach(viewStore.stages) { stage in
                    Text(stage.name)
                        .frame(maxWidth: .infinity)
                        .font(.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                }
            }
        }
    }
}

struct TimelineHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            TimelineHeaderView(
                store: .init(
                    initialState: .init(
                        selectedDate: Event.testData.festivalDates.first!,
                        stages: Stage.testValues.asIdentifedArray,
                        festivalDates: [Date.now]
                    ),
                    reducer: timelineHeaderReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
