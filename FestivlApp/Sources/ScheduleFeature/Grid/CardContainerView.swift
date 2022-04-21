//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/20/22.
//

import SwiftUI
import ComposableArchitecture
import Models

struct CardContainerView: View {

    var style: ScheduleStyle
    let store: Store<ScheduleState, ScheduleAction>

    func artistSets(for viewStore: ViewStore<ScheduleState, ScheduleAction>) -> IdentifiedArrayOf<ScheduleItem> {

        switch style {
        case .singleStage(let stage):
            return viewStore.schedule[.init(
                date: viewStore.selectedDate,
                stageID: stage.id!
            )] ?? .init()

        case .allStages:
            return viewStore.schedule.keys.filter {
                $0.date == viewStore.selectedDate
            }
            .flatMap {
                viewStore.schedule[$0] ?? .init()
            }
            .asIdentifedArray

        }
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geo in
                ZStack {
                    let stageCount = style == .allStages ? viewStore.stages.count : 1

                    ForEach(artistSets(for: viewStore)) { scheduleItem in

                        let size = scheduleItem.size(in: geo.size, stageCount: stageCount)
                        // Placement works by center of the view, move it to the top left
                        let offset = CGSize(width: size.width / 2, height: size.height / 2)

                        let xPosition = style == .allStages ?  scheduleItem.xPlacement(
                            stageCount: stageCount,
                            containerWidth: geo.size.width,
                            stages: viewStore.stages
                        ) : 0

                        ScheduleCardView(
                            scheduleItem,
                            stages: viewStore.stages,
                            isSelected: viewStore.cardToDisplay == scheduleItem
                        )
                        .id(scheduleItem.id)
                        .frame(size: size)
                        //                        .fixedSize()
                        .position(
                            x: xPosition + offset.width,
                            y: scheduleItem.yPlacement(dayStartsAtNoon: viewStore.event.dayStartsAtNoon, containerHeight: geo.size.height) + offset.height
                        )

                        .onTapGesture {
                            viewStore.send(.didTapCard(scheduleItem))
                        }

                    }

                }
            }

        }


    }

}

struct CardContainerView_Previews: PreviewProvider {
    static var previews: some View {
        CardContainerView(style: .singleStage(.testValues[0]), store: .testStore)
    }
}
