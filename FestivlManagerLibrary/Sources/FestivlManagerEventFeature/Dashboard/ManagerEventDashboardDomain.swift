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
                isPresentingDeleteConfirmation: isPresentingArtistDeleteConfirmation
            )
        }
        set {
            self.artists = newValue.artists
            self.artistListSelectedArtist = newValue.selectedArtist
            self.event = newValue.event
            self.createArtistState = newValue.createArtistState
            self.isPresentingArtistDeleteConfirmation = newValue.isPresentingDeleteConfirmation
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
}

public enum ManagerEventDashboardAction: BindableAction {
    case binding(_ action: BindingAction<FestivlManagerEventState>)
    case artistsAction(ManagerArtistsAction)
    case stagesAction(StagesAction)

    case exitEvent
}

public struct ManagerEventDashboardEnvironment {
    public init() {}
}

public let managerEventDashboardReducer = Reducer.combine(

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

    Reducer<FestivlManagerEventState, ManagerEventDashboardAction, ManagerEventDashboardEnvironment> { state, action, _ in
        switch action {
        case .binding:
            return .none
        case .exitEvent:
            // Handled at top level
            return .none
        case .artistsAction:
            return .none
        case .stagesAction:
            return .none
        }
    }
    .binding()

)


