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
        var cardToDisplay: ScheduleItem.ID?
        var showingComingSoonScreen: Bool
        
        var selectedStage: Stage.ID
        private var selectedDate: CalendarDate
        
        init(state: ScheduleFeature.State) {
           

            self.stages = state.stages
            self.cardToDisplay = state.cardToDisplay
            self.showingComingSoonScreen = state.showingComingSoonScreen
            self.selectedStage = state.selectedStage
            self.selectedDate = state.selectedDate
            
            var selectedDaySchedule: [Stage.ID : [ScheduleItem]] = [:]
            
            for stage in stages {
                selectedDaySchedule[stage.id] = Array(state.schedule[schedulePage: .init(date: state.selectedDate, stageID: stage.id)])
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

extension Dictionary: CustomDumpStringConvertible where Key == Stage.ID, Value == [ScheduleItem] {
    public var customDumpDescription: String {
        return "Schedule(...)"
    }
}

extension IdentifiedArray: CustomDumpStringConvertible where Element == Stage {
    public var customDumpDescription: String {
        return "Stages(...)"
    }
}

struct SingleStageContent: View {
    var viewStore: ViewStore<SingleStageAtOnceView.ViewState, ScheduleFeature.Action>
    
    var body: some View {
        let _ = customDump(viewStore)
        Group {
            if viewStore.showingComingSoonScreen {
                ScheduleComingSoonView()
            } else {
                SelectingScrollView(selecting: viewStore.cardToDisplay) {
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
                                        isSelected: viewStore.cardToDisplay == scheduleItem.id
                                    )
                                }
                                .tag(scheduleItem.id)
                            }
                            .id(stage.id) // Needed to prevent bug where TabView doesn't stay synced properly when jumping over many pages
                            .tag(stage.id)
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
