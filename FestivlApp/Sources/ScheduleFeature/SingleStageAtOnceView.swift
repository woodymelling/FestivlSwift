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
                    state.schedule[schedulePage: .init(date: state.selectedDate, stageID: stage.id)]
                    .filter { !state.filteringFavorites || state.userFavorites.contains($0) }
                
            }
            
            self.selectedDaySchedule = selectedDaySchedule
        }
    }
        
    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            SingleStageContent(viewStore: viewStore)
        }
    }
}
extension ScheduleItem: TimeRangeRepresentable {
    public var timeRange: Range<Date> { startTime..<endTime }
}

struct SingleStageContent: View {
    var viewStore: ViewStore<SingleStageAtOnceView.ViewState, ScheduleFeature.Action>
    
    var body: some View {
        Group {
            if viewStore.showingComingSoonScreen {
                ScheduleComingSoonView()
            } else {
                DateSelectingScrollView(selecting: viewStore.cardToDisplay?.startTime) {

                    TabView(
                        selection: viewStore.binding(
                            get: { $0.selectedStage },
                            send: { .binding(.set(\.$selectedStage, $0)) }
                        ).animation(.default)
                    ) {
                        ForEach(viewStore.stages) { stage in
                            SchedulePageView(viewStore.selectedDaySchedule[stage.id] ?? []) { scheduleItem in

                                Button {
                                    viewStore.send(.didTapCard(scheduleItem))
                                } label: {
                                    ScheduleCardView(
                                        scheduleItem,
                                        isSelected: viewStore.cardToDisplay == scheduleItem,
                                        isFavorite: viewStore.userFavorites.contains(scheduleItem)
                                    )
                                }
                                .id(scheduleItem.id)
                                .tag(scheduleItem.id)
                            }
                            .tag(stage.id)
                            .id(stage.id) // Needed to prevent bug where TabView doesn't stay synced properly when jumping over many pages
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
                selectedStage: viewStore.binding(
                    get: { $0.selectedStage },
                    send: { .binding(.set(\.$selectedStage, $0)) }
                ).animation(.default)
            )
        }
    }
}



//struct SingleStageAtOnceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleStageAtOnceView(
//            store: .testStore
//        )
//        .previewAllColorModes()
////        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
//    }
//
//}
