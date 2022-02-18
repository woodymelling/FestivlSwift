//
//  Schedule.swift
//
//
//  Created by Woody on 2/18/2022.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct ScheduleView: View {
    let store: Store<ScheduleState, ScheduleAction>

    public init(store: Store<ScheduleState, ScheduleAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                SingleStageAtOnceView(store: store)
                    .toolbar {
                        ToolbarItem(placement: .principal, content: {
                            Menu {
                                ForEach(viewStore.event.festivalDates, id: \.self, content: { date in
                                    Button(action: {
                                        viewStore.send(.selectedDate(date), animation: .default)
                                    }, label: {
                                        Text(date.formatted(.dateTime.weekday(.wide)))
                                    })
                                })
                            } label: {
                                HStack {
                                    Text(viewStore.selectedDate.formatted(.dateTime.weekday(.wide)))
                                        .font(.title2)
                                    Image(systemName: "chevron.down")

                                }
                                .foregroundColor(.primary)
                            }
                        })
                    }
                    .navigationBarTitleDisplayMode(.inline)
            }

        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ScheduleView(
                store: .init(
                    initialState: .init(
                        stages: Stage.testValues.asIdentifedArray,
                        selectedStage: Stage.testValues[0],
                        event: .testData,
                        selectedDate: Event.testData.festivalDates[0]
                    ),
                    reducer: scheduleReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}


