//
//  ManagerScheduleView.swift
//
//
//  Created by Woody on 3/28/2022.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct ManagerTimelineView: View {
    let store: Store<ManagerScheduleState, ManagerScheduleAction>

    public init(store: Store<ManagerScheduleState, ManagerScheduleAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack(alignment: .top) {
                VStack {
                    TimelineHeaderView(store: store.scope(
                        state: \.headerState,
                        action: ManagerScheduleAction.headerAction
                    ))
                    .padding(.leading, 45)

                    ScrollView {
                        HStack {
                            ScheduleHourLabelsView(
                                dayStartsAtNoon: viewStore.event.dayStartsAtNoon
                            )
                            .frame(width: 45)

                            ZStack {
                                GridView(
                                    timelineHeight: viewStore.timelineHeight,
                                    stageCount: viewStore.stages.count
                                )
                                
                                ManagerCardsContainerView(store: store)
                            }

                        }
                        .padding(.vertical)
                    }

                }

                VStack {
                    ScheduleZoomSlider(
                        zoomAmount: viewStore.binding(\.$zoomAmount)
                    )
                    .frame(height: 200)

                    Spacer()

                    ScheduleDeleteView(store: store)
                        .padding(.bottom)
                }
                .frame(width: 80)
                .padding(.top, 100)
            }
        }
    }
}

struct ManagerTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ManagerTimelineView(
                store: .previewStore
            )
            .preferredColorScheme($0)
        }
    }
}
