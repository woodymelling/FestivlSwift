//
//  ManagerScheduleView.swift
//
//
//  Created by Woody on 3/28/2022.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct ManagerScheduleView: View {
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
//                                CardsContainer()
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
    }
}

struct ManagerScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ManagerScheduleView(
                store: .previewStore
            )
            .preferredColorScheme($0)
        }
    }
}
