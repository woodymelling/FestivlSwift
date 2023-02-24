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
    let store: StoreOf<ScheduleFeature>

    func artistSets(for viewStore: ViewStoreOf<ScheduleFeature>) -> [ScheduleItem] {
        switch style {
        case .singleStage(let stage):
            
            let pageIdentifier = Schedule.PageKey(date: viewStore.selectedDate, stageID: stage.id)
            return viewStore.schedule[schedulePage: pageIdentifier].filter {
                if viewStore.isFiltering {
                    return $0.isIncludedInFavorites(userFavorites: viewStore.userFavorites)
                } else {
                    return true
                }
            }

        case .allStages:
            
            return Array(
                viewStore.stages
                    .map { Schedule.PageKey(date: viewStore.selectedDate, stageID: $0.id) }
                    .reduce(Set<ScheduleItem>()) { partialResult, pageIdentifier in
                        partialResult.union(viewStore.schedule[schedulePage: pageIdentifier])
                    }
                    .filter {
                        if viewStore.isFiltering {
                            return $0.isIncludedInFavorites(userFavorites: viewStore.userFavorites)
                        } else {
                            return true
                        }
                    }
            )
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

                        let xPosition = style == .allStages ? scheduleItem.xPlacement(
                            stageCount: stageCount,
                            containerWidth: geo.size.width,
                            stages: viewStore.stages
                        ) : 0

                        ScheduleCardView(
                            scheduleItem,
                            stages: viewStore.stages,
                            isSelected: viewStore.cardToDisplay == scheduleItem,
                            isFavorite: ScheduleFeature.isFavorited(
                                scheduleItem,
                                favorites: viewStore.userFavorites
                            )
                        )
                        .onTapGesture {
                            viewStore.send(.didTapCard(scheduleItem))
                        }
                        .id(scheduleItem.id)
                        .frame(size: size)
                        //                        .fixedSize()
                        .position(
                            x: xPosition + offset.width,
                            y: scheduleItem.yPlacement(dayStartsAtNoon: viewStore.event.dayStartsAtNoon, containerHeight: geo.size.height) + offset.height
                        )
                    }

                }
            }

        }


    }

}

//struct CardContainerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardContainerView(style: .singleStage(.testValues[0]), store: .testStore)
//    }
//}
