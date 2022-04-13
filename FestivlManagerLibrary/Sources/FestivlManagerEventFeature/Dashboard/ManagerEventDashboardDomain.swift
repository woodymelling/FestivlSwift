//
// ManagerEventDashboardDomain.swift
//
//
//  Created by Woody on 3/9/2022.
//

import ComposableArchitecture
import Models
import ManagerArtistsFeature
import CreateArtistFeature
import StagesFeature
import ManagerScheduleFeature
import AddEditEventFeature

public enum SidebarPage {
    case artists, stages, schedule

    var isThreeColumn: Bool {
        switch self {
        case .artists, .stages:
            return true
        case .schedule:
            return false
        }
    }
}

extension FestivlManagerEventState {
    var artistsState: ManagerArtistsState {
        get {
            return .init(
                artists: artists,
                selectedArtist: artistListSelectedArtist,
                event: event,
                createArtistState: createArtistState,
                isPresentingDeleteConfirmation: isPresentingArtistDeleteConfirmation,
                bulkAddState: artistBulkAddState,
                searchText: artistListSearchText
            )
        }
        set {
            self.artists = newValue.artists
            self.artistListSelectedArtist = newValue.selectedArtist
            self.event = newValue.event
            self.createArtistState = newValue.createArtistState
            self.isPresentingArtistDeleteConfirmation = newValue.isPresentingDeleteConfirmation
            self.artistBulkAddState = newValue.bulkAddState
            self.artistListSearchText = newValue.searchText
        }
    }

    var stagesState: StagesState {
        get {
            StagesState(
                stages: stages,
                event: event,
                selectedStage: stagesListSelectedStage,
                addEditStageState: addEditStageState,
                isPresentingDeleteConfirmation: isPresentingStageDeleteConfirmation
            )
        }

        set {
            self.stages = newValue.stages
            self.event = newValue.event
            self.stagesListSelectedStage = newValue.selectedStage
            self.addEditStageState = newValue.addEditStageState
            self.isPresentingStageDeleteConfirmation = newValue.isPresentingDeleteConfirmation
        }
    }

    var scheduleState: ManagerScheduleState {
        get {
            ManagerScheduleState(
                event: self.event,
                selectedDate: self.scheduleSelectedDate,
                zoomAmount: self.scheduleZoomAmount,
                artists: self.artists,
                stages: self.stages,
                artistSets: self.artistSets,
                groupSets: self.groupSets,
                addEditArtistSetState: self.addEditArtistSetState,
                artistSearchText: self.scheduleArtistSearchText
            )
        }

        set {
            self.scheduleSelectedDate = newValue.selectedDate
            self.scheduleZoomAmount = newValue.zoomAmount
            self.addEditArtistSetState = newValue.addEditArtistSetState
            self.artistSets = newValue.artistSets
            self.groupSets = newValue.groupSets
            self.scheduleArtistSearchText = newValue.artistSearchText
        }
    }
}

public enum ManagerEventDashboardAction: BindableAction {
    case binding(_ action: BindingAction<FestivlManagerEventState>)
    case artistsAction(ManagerArtistsAction)
    case stagesAction(StagesAction)
    case scheduleAction(ManagerScheduleAction)
    case editEventAction(AddEditEventAction)

    case editEvent
    case exitEvent
}

public struct ManagerEventDashboardEnvironment {
    public init() {}
}

public let managerEventDashboardReducer = Reducer.combine(

    addEditEventReducer.optional().pullback(
        state: \FestivlManagerEventState.editEventState,
        action: /ManagerEventDashboardAction.editEventAction,
        environment: { _ in .init() }
    ),

    managerArtistsReducer.pullback(
        state: \FestivlManagerEventState.artistsState,
        action: /ManagerEventDashboardAction.artistsAction,
        environment: { _ in .init() }
    ),

    stagesReducer.pullback(
        state: \FestivlManagerEventState.stagesState,
        action: /ManagerEventDashboardAction.stagesAction,
        environment: { _ in .init() }
    ),

    managerScheduleReducer.pullback(
        state: \FestivlManagerEventState.scheduleState,
        action: /ManagerEventDashboardAction.scheduleAction,
        environment: { _ in .init() }
    ),

    Reducer<FestivlManagerEventState, ManagerEventDashboardAction, ManagerEventDashboardEnvironment> { state, action, _ in
        switch action {
        case .binding:
            return .none
        case .exitEvent:
            // Handled at top level
            return .none

        case .editEvent:
            state.editEventState = .init(editing: state.event)
            return .none

        case .editEventAction(.closeModal):
            state.editEventState = nil
            return .none
        case .artistsAction, .stagesAction, .scheduleAction, .editEventAction:
            return .none
        }
    }
    .binding()

)


