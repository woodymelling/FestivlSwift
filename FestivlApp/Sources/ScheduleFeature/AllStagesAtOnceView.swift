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

struct AllStagesAtOnceView: View {
    let store: StoreOf<ScheduleFeature>
    let date: CalendarDate
    
    struct ViewState: Equatable {
        var schedule: [ScheduleItem]
        var stages: IdentifiedArrayOf<Stage>
        var selectedCard: ScheduleItem.ID?
        var selectedDate: CalendarDate
        
        init(_ state: ScheduleFeature.State, date: CalendarDate) {
           
            self.schedule = Array(
                state.stages
                    .map { Schedule.PageKey(date: date, stageID: $0.id) }
                    .reduce(Set<ScheduleItem>()) { partialResult, pageIdentifier in
                        partialResult.union(state.schedule[schedulePage: pageIdentifier])
                    }
                    .filter {
                        if state.isFiltering {
                            return $0.isFavorite
                        } else {
                            return true
                        }
                    }
            )
            
            self.stages = state.stages
            self.selectedDate = state.selectedDate
            self.selectedCard = state.cardToDisplay
        }
    }

    var body: some View {
        WithViewStore(store, observe: { ViewState($0, date: self.date) }) { viewStore in
            SelectingScrollView(selecting: viewStore.selectedCard) {
                
                SchedulePageView(viewStore.schedule) { scheduleItem in
                    Button {
                        viewStore.send(.didTapCard(scheduleItem))
                    } label: {
                        ScheduleCardView(
                            scheduleItem,
                            isSelected: viewStore.selectedCard == scheduleItem.id
                        )
                    }
                    .tag(scheduleItem)
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
                CachedAsyncImage(url: stage.iconImageURL, renderingMode: .template, placeholder: {
                    ProgressView()
                })
                .foregroundColor(stage.color)
                .frame(square: 50)

            }
        }
    }
}
