//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/21/22.
//

import SwiftUI
import ComposableArchitecture
import Models
import Components
import Utilities
import ScheduleComponents
import FestivlDependencies

struct AllStagesAtOnceView: View {
    let store: StoreOf<ScheduleFeature>
    let date: CalendarDate
    
    struct ViewState: Equatable {
        var schedule: [TimelineWrapper<ScheduleItem>]
        var stages: IdentifiedArrayOf<Stage>
        var selectedCard: ScheduleItem?
        var selectedDate: CalendarDate
        var userFavorites: UserFavorites
        
        init(_ state: ScheduleFeature.State, date: CalendarDate) {
            self.userFavorites = state.userFavorites
            self.stages = state.stages
            
            self.schedule = state.stages
                .map { Schedule.PageKey(date: date, stageID: $0.id) }
                .reduce([ScheduleItem]()) { partialResult, pageIdentifier in
                    partialResult + state.schedule[page: pageIdentifier]
                }
                .filter {
                    if state.isFiltering {
                        return state.userFavorites.contains($0)
                    } else {
                        return true
                    }
                }
                .map {
                    let stageIndex = state.stages[id: $0.stageID]?.sortIndex ?? 0
                    return TimelineWrapper(groupWidth: stageIndex..<stageIndex, item: $0)
                }

            
            self.selectedDate = state.selectedDate
            self.selectedCard = state.cardToDisplay
        }
    }
    
    @Environment(\.stages) var stages

    var body: some View {
        WithViewStore(store, observe: { ViewState($0, date: self.date) }) { viewStore in
            DateSelectingScrollView(selecting: viewStore.selectedCard?.startTime) {
                SchedulePageView(viewStore.schedule) { scheduleItem in
                    Button {
                        viewStore.send(.didTapCard(scheduleItem.item))
                    } label: {
                        ScheduleCardView(
                            scheduleItem.item,
                            isSelected: viewStore.selectedCard == scheduleItem.item,
                            isFavorite: viewStore.userFavorites.contains(scheduleItem.item)
                        )
                    }
                    .tag(scheduleItem.item)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    StagesIndicatorView(stages: viewStore.stages)
                }
            }
        }
    }
}

struct StagesIndicatorView: View {
    var stages: IdentifiedArrayOf<Stage>
    var body: some View {
        HStack {
            ForEach(stages) { stage in
                CachedAsyncIcon(url: stage.iconImageURL) {
                    ProgressView()
                }
                .foregroundColor(stage.color)
                .frame(square: 50)

            }
        }
    }
}
