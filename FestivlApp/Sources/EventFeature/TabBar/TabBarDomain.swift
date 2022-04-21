//
//  File.swift
//  
//
//  Created by Woody on 2/14/22.
//

import Foundation
import ComposableArchitecture
import Models
import ArtistListFeature
import ScheduleFeature
import SwiftUI
import ExploreFeature


public enum Tab {
    case schedule, artists, explore, settings
}

public extension EventState {
    
    var artistListState: ArtistListState {
        get {
            .init(
                event: event,
                artists: artists,
                stages: stages,
                schedule: schedule,
                searchText: artistListSearchText
            )
        }

        set {
            self.artistListSearchText = newValue.searchText
        }
    }

    var scheduleState: ScheduleState {
        get {
            .init(
                artists: artists,
                stages: stages,
                schedule: schedule,
                selectedStage: scheduleSelectedStage,
                event: event,
                zoomAmount: scheduleZoomAmount,
                lastScaleValue: scheduleLastScaleValue,
                selectedDate: scheduleSelectedDate,
                cardToDisplay: scheduleCardToDisplay,
                selectedArtistState: scheduleSelectedArtistState,
                selectedGroupSetState: selectedGroupSetState,
                deviceOrientation: deviceOrientation,
                currentTime: currentTime
            )
        }

        set {
            self.scheduleZoomAmount = newValue.zoomAmount
            self.scheduleLastScaleValue = newValue.lastScaleValue
            self.scheduleSelectedDate = newValue.selectedDate
            self.scheduleSelectedStage = newValue.selectedStage
            self.scheduleCardToDisplay = newValue.cardToDisplay
            self.scheduleSelectedArtistState = newValue.selectedArtistState
            self.selectedGroupSetState = newValue.selectedGroupSetState
            self.deviceOrientation = newValue.deviceOrientation
            self.currentTime = newValue.currentTime
        }
    }

    var exploreState: ExploreState {
        get {
            .init(
                artists: exploreArtists,
                event: event,
                stages: stages,
                schedule: schedule,
                selectedArtistPageState: exploreSelectedArtistState
            )
        }

        set {
            self.exploreArtists = newValue.artists
            self.exploreSelectedArtistState = newValue.selectedArtistPageState
        }
    }
}

public enum TabBarAction: BindableAction {
    case binding(_ action: BindingAction<EventState>)
    case artistListAction(ArtistListAction)
    case scheduleAction(ScheduleAction)
    case exploreAction(ExploreAction)
}

public struct TabBarEnvironment {
    public init() { }
}

public let tabBarReducer = Reducer.combine(
    Reducer<EventState, TabBarAction, TabBarEnvironment> { state, action, _ in
        switch action {
        case .binding:
            return .none
        case .artistListAction(.artistDetail(_, .didTapArtistSet(let scheduleCard))), .exploreAction(.artistPage(_, .didTapArtistSet(let scheduleCard))):
            state.selectedTab = .schedule
            return Effect(value: .scheduleAction(.showAndHighlightCard(scheduleCard)))

        case .artistListAction, .scheduleAction:
            return .none

        case .exploreAction:
            return .none
        }
    }
    .binding(),

    artistListReducer.pullback(
        state: \EventState.artistListState,
        action: /TabBarAction.artistListAction,
        environment: { (_: TabBarEnvironment) in ArtistListEnvironment() }
    ),

    scheduleReducer.pullback(
        state: \EventState.scheduleState,
        action: /TabBarAction.scheduleAction,
        environment: { _ in ScheduleEnvironment() }),

    exploreReducer.pullback(
        state: \EventState.exploreState,
        action: /TabBarAction.exploreAction,
        environment: { _ in .init()}
    )
)
