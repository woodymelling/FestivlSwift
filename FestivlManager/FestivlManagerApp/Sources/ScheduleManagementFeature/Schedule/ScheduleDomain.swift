//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/4/23.
//

import Foundation
import ComposableArchitecture
import FestivlDependencies
import Models
import Utilities
import Dependencies
import Tagged
import SwiftUI
import ScheduleComponents

/**
 ScheduleDomain holds onto the state of the schedule. It has a page which holds onto stages. ScheduleDomain only passes the sets for the day is selected to each stage.
 We derive the current schedule page from stages, and a dictionary which goes from CalendarDate -> [StageID: [Cards]].
 This dictionary is the schedule for each day, indexed by stage within each day.
 This process of deriving the state *should* be O(n) based on the number of stages, not great, but never too bad.
 
 Creating the schedule domain is where the complexity happens, but it really should just be O(n) based on the number of sets.
 */
@Reducer
public struct ScheduleDomain {
    @Dependency(\.scheduleClient) var scheduleClient
    @Dependency(\.stageClient) var stageClient
    
    public struct State: Equatable {
        @BindingState var selectedDate: CalendarDate
        var stages: Stages
        var event: Event
        
        var cardsPerDay: [CalendarDate : [Stage.ID : IdentifiedArrayOf<ScheduleCardDomain.State>]] // This could be moved to schedule and have an index get made.
        
        var schedulePageState: SchedulePageDomain.State {
            get {
                SchedulePageDomain.State(
                    stageStates: stages.map {
                        StageDomain.State(
                            stage: $0,
                            cards: (cardsPerDay[selectedDate]?[$0.id] ?? []).asIdentifiedArray(unchecked: true)
                        )
                    }.asIdentifiedArray(unchecked: true)
                )
            }
            
            set {
                self.stages = newValue.stageStates
                    .map { $0.stage }
                    .asIdentifiedArray(unchecked: true)
                
                self.cardsPerDay.updateValue(
                    newValue.stageStates.reduce(into: [:]) { initialResult, stageState in
                        initialResult.updateValue(stageState.cards, forKey: stageState.id)
                    },
                    forKey: selectedDate
                )
            }
        }
        
        init(schedule: Models.Schedule, stages: Stages, event: Event, selectedDate: CalendarDate) {
            print("Selected:", selectedDate, "Event Days:", event.festivalDates)
            
            self.selectedDate = selectedDate
            self.stages = stages
            self.event = event // For view injection, remove later.

            
            // Convert the raw data passed in to the correct state structure.
            // TODO: Refactor this so it's actually readable.
            self.cardsPerDay = event.festivalDates.reduce(into: [:]) { partialResult, day in
                partialResult[day] = stages.reduce(into: [:]) { partialResult, stage in
                    partialResult.updateValue(
                        schedule[page: .init(date: day, stageID: stage.id)].map {
                            ScheduleCardDomain.State(scheduleItem: $0, isSelected: false)
                        }.asIdentifiedArray(unchecked: true),
                        forKey: stage.id
                    )
                }
            }
        }

    }
    
    public enum Action: Equatable, BindableAction {
        
        case didTapUpdateDates
        
        case page(SchedulePageDomain.Action)
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .binding(\.$selectedDate):
                print("Selected Date \(state.selectedDate)")
                
                return .none
                
            case .didTapUpdateDates:
                return .none
                
            case .binding, .page:
                return .none
            }
        }
       
        Scope(state: \.schedulePageState, action: /Action.page) {
            SchedulePageDomain()
        }
    }
}

public struct SchedulePageDomain: Reducer {
    public struct State: Equatable {
        var stageStates: IdentifiedArrayOf<StageDomain.State>
    }
    
    public enum Action: Equatable {
        case didReorderStages(IdentifiedArrayOf<StageDomain.State>)
        case stage(id: StageDomain.State.ID, action: StageDomain.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            
            switch action {
            case .stage:
                return .none
            case let .didReorderStages(newOrder):
                
                state.stageStates = newOrder
                return .none
            }
        }
        .forEach(\.stageStates, action: /Action.stage) {
            StageDomain()
        }
    }
}
import OSLog


public struct StageDomain: Reducer {
    public struct State: Identifiable, Equatable {
        public var id: Stage.ID { stage.id }
        var stage: Stage
        
        var cards: IdentifiedArrayOf<ScheduleCardDomain.State>
        
        init(stage: Stage, cards: IdentifiedArrayOf<ScheduleCardDomain.State>) {
            self.stage = stage
            self.cards = cards
        }
        
    }
    
    public enum Action: Equatable {
        case didReorderStages
        
        case card(id: ScheduleCardDomain.State.ID, action: ScheduleCardDomain.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            return .none
        }
        .forEach(\.cards, action: /Action.card) {
            ScheduleCardDomain()
        }
    }
}


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

