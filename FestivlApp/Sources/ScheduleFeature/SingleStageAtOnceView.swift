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
import ScheduleComponents
import FestivlDependencies

extension View {
    func toolbarBackground(style: some ShapeStyle) -> some View {
        if #available(iOS 16, *) {
            return self
                .toolbarBackground(style)
        } else {
            return self
        }
    }
}

public struct SingleStageAtOnceView: View {
    let store: StoreOf<ScheduleFeature>
    
    public init(store: StoreOf<ScheduleFeature>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        var selectedDaySchedule: [Stage.ID: [ScheduleItem]]
        var stages: IdentifiedArrayOf<Stage>
        var cardToDisplay: ScheduleItem?
        var showingComingSoonScreen: Bool
        var userFavorites: UserFavorites
        
        var selectedStage: Stage.ID
        private var selectedDate: CalendarDate
        
        init(state: ScheduleFeature.State) {
            self.stages = state.stages
            self.cardToDisplay = state.cardToDisplay
            self.showingComingSoonScreen = state.showingComingSoonScreen
            self.selectedStage = state.selectedStage
            self.selectedDate = state.selectedDate
            self.userFavorites = state.userFavorites
            
            
            var selectedDaySchedule: [Stage.ID : [ScheduleItem]] = [:]
            
            for stage in stages {
                selectedDaySchedule[stage.id] =
                    state.schedule[page: .init(date: state.selectedDate, stageID: stage.id)]
                    .filter { !state.filteringFavorites || state.userFavorites.contains($0) }
                
            }
            
            self.selectedDaySchedule = selectedDaySchedule
        }
    }
    
//    @State var selectedStageID: Stage.ID = .init("")
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.showingComingSoonScreen {
                    ScheduleComingSoonView()
                } else {
                    DateSelectingScrollView(selecting: viewStore.cardToDisplay?.startTime) {

                        TabView(selection: viewStore.$selectedStage) {
                            
                            ForEach(viewStore.stages) { stage in
                                SchedulePageView(viewStore.schedule[page: .init(date: viewStore.selectedDate, stageID: stage.id)]) { scheduleItem in
                                    
                                    ScheduleCardView(
                                        scheduleItem,
                                        isSelected: viewStore.cardToDisplay == scheduleItem,
                                        isFavorite: viewStore.userFavorites.contains(scheduleItem)
                                    )
                                    .onTapGesture {
                                        viewStore.send(.didTapCard(scheduleItem))
                                    }
                                    .tag(scheduleItem.id)
                                }
                                .tag(stage)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 1500)
                    }
                }
            }
            .toolbarBackground(style: Color.systemBackground)
            .safeAreaInset(edge: .top) {
                ScheduleStageSelector(
                    stages: viewStore.stages,
                    selectedStage: viewStore.selectedStage,
                    onSelectStage: { viewStore.send(.didSelectStage($0), animation: .default) }
                )
                
            }
        }
    }
}
