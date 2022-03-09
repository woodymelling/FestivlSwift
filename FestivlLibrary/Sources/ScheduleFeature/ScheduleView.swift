//
//  Schedule.swift
//
//
//  Created by Woody on 2/18/2022.
//

import SwiftUI
import ComposableArchitecture
import Models

enum ScheduleStyle: Equatable {
    case singleStage(Stage)
    case allStages
}

public struct ScheduleView: View {
    let store: Store<ScheduleState, ScheduleAction>
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    public init(store: Store<ScheduleState, ScheduleAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Group {
                    if horizontalSizeClass == .compact {
                        SingleStageAtOnceView(store: store)
                    } else {
                        AllStagesAtOnceView(store: store)
                    }
                }
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
            .navigationViewStyle(.stack)
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            let time = Event.testData.festivalDates[0]
            ScheduleView(
                store: .init(
                    initialState: .init(
                        stages: Stage.testValues.asIdentifedArray,
                        artistSets: ArtistSet.testValues(startTime: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: time)!).asIdentifedArray,
                        selectedStage: Stage.testValues[0],
                        event: .testData,
                        selectedDate: time
                    ),
                    reducer: scheduleReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}


