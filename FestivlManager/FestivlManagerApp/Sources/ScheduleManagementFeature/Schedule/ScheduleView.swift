//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 7/4/23.
//

import SwiftUI
import ComposableArchitecture
import ScheduleComponents
import Models
import Utilities
import Components

struct ScheduleView: View {
    let store: StoreOf<ScheduleDomain>
    
    struct ViewState: Equatable {
        @BindingViewState var selectedDay: CalendarDate
        
        // For view environment, remove eventually
        var stages: Stages
        var event: Event
        
        init(_ state: BindingViewStore<ScheduleDomain.State>) {
            self._selectedDay = state.$selectedDate
            self.stages = state.stages
            self.event = state.event
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Color.systemBackground
                .frame(height: 1)
                .ignoresSafeArea()
            
            WithViewStore(store, observe: ViewState.init) { viewStore in
                SchedulePageView(
                    store: store.scope(
                        state: \.schedulePageState,
                        action: ScheduleDomain.Action.page
                    )
                )
                .toolbarDateSelector(selectedDate: viewStore.$selectedDay)
                .environment(\.event, viewStore.event)
                .environment(\.dayStartsAtNoon, viewStore.event.dayStartsAtNoon)
                .environment(\.stages, viewStore.stages)
            }
        }
    }
}


struct SchedulePageView: View {
    let store: StoreOf<SchedulePageDomain>
    
    @State var hourLabelsWidth: CGFloat = 0
    @State var stageTitleHeight: CGFloat = 0
    
    @State var draggingStageID: Stage.ID?

    var body: some View {
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                
                ZStack(alignment: .topLeading) {
                    ScheduleGrid()
                        .padding(.top, stageTitleHeight)
                    
                    HStack(spacing: 0) {
                        ForEachStore(
                            store.scope(state: \.stageStates, action: SchedulePageDomain.Action.stage)
                        ) { stageStore in
                            StageView(store: stageStore)
                                .onDrag {
                                    self.draggingStageID = stageStore.withState { $0.id }
                                    return NSItemProvider()
                                } preview: {
                                    EmptyView()
                                }
                                .onDrop(
                                    of: [.text],
                                    delegate: StageDropDelegate(
                                        destinationStage: stageStore.withState { $0.id },
                                        draggedStage: $draggingStageID,
                                        stages: .init(
                                            get: { viewStore.stageStates },
                                            set: { viewStore.send(.didReorderStages($0)) }
                                        )
                                    )
                                )
                                .zIndex(1)
                            
                            Divider()
                                .padding(.top, stageTitleHeight)
                                .zIndex(0)
                        }
                    }
                    .padding(.leading, hourLabelsWidth + 7) // Needs plus 7 to align properly. Bad practice :(
                }
            }
        }
        
        .onPreferenceChange(HourLabelsWidthPreferenceKey.self) { self.hourLabelsWidth = $0 }
        .onPreferenceChange(StageTitleHeightPreferenceKey.self) { self.stageTitleHeight = $0 }
        .overlay(alignment: .topLeading) {
            Rectangle()
                .fill(Color.systemBackground)
                .frame(width: hourLabelsWidth, height: stageTitleHeight.floor(at: 5) - 5)
                .shadow(color: .systemBackground, radius: 5)
        }

    }
    
    struct StageDropDelegate: DropDelegate {
        
        var destinationStage: Stage.ID
        @Binding var draggedStage: Stage.ID?
        @Binding var stages: IdentifiedArrayOf<StageDomain.State>
        
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            return DropProposal(operation: .move)
        }
        
        func dropEntered(info: DropInfo) {
            
            if let draggedStage,
               let fromIndex = stages.index(id: draggedStage),
               let toIndex = stages.index(id: destinationStage),
               fromIndex != toIndex
            {
                withAnimation {
                    self.stages.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                }
            }
        }
        
        func performDrop(info: DropInfo) -> Bool {
            draggedStage = nil
            return true
        }
    }
}


struct StageTitleHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct StageView: View {
    let store: StoreOf<StageDomain>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                Section {
                    ZStack {
                        ForEachStore(store.scope(state: { $0.cards } , action: StageDomain.Action.card)) {
                            ScheduleCardView(store: $0)
                        }
                    }
                        
                    .frame(height: 1500)
                    
                } header: {
                    
                    Text(viewStore.stage.name)
                        .font(.title2)
                        .fontWeight(.thin)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .minimumScaleFactor(0.6)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.systemBackground)
                        .heightReader(updating: StageTitleHeightPreferenceKey.self)
                }
                
                

            }
        }
    }
}

#Preview("Schedule View") {
    NavigationStack {
        ScheduleView(store: Store(
            initialState: ScheduleDomain.State.init(
                schedule: .previewData,
                stages: .previewData,
                event: .previewData,
                selectedDate: Event.previewData.startDate
            ),
            reducer: { ScheduleDomain()._printChanges() }))
        .environment(\.stages, .previewData)
        .environment(\.event, .previewData)
    }
}


