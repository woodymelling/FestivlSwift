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
import MoreFeature


public enum Tab {
    case schedule, artists, explore, more
}

public extension EventFeature.State {
    
    var artistListState: ArtistListFeature.State {
        get {
            .init(
                event: event,
                artists: artists,
                stages: stages,
                schedule: schedule,
                searchText: artistListSearchText,
                favoriteArtists: favoriteArtists,
                showArtistImages: !exploreArtists.isEmpty
            )
        }

        set {
            self.artistListSearchText = newValue.searchText
            self.favoriteArtists = Set(newValue.artistStates.filter { $0.isFavorite }.map { $0.artist.id! })
        }
    }

    var scheduleState: ScheduleFeature.State {
        get {
            .init(
                artists: artists,
                stages: stages,
                schedule: schedule,
                event: event,
                favoriteArtists: favoriteArtists,
                selectedStage: scheduleSelectedStage,
                selectedDate: scheduleSelectedDate,
                filteringFavorites: scheduleFilteringFavorites,
                zoomAmount: scheduleZoomAmount,
                lastScaleValue: scheduleLastScaleValue,
                cardToDisplay: scheduleCardToDisplay,
                selectedArtistState: scheduleSelectedArtistState,
                selectedGroupSetState: selectedGroupSetState,
                deviceOrientation: deviceOrientation,
                currentTime: currentTime,
                hasShownTutorialElements: hasDisplayedTutorialElements,
                showingLandscapeTutorial: showingLandscapeTutorial,
                showingFilterTutorial: showingFilterTutorial,
                showArtistImages: !exploreArtists.isEmpty
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
            self.scheduleFilteringFavorites = newValue.filteringFavorites
            self.hasDisplayedTutorialElements = newValue.hasShownTutorialElements
            self.showingLandscapeTutorial = newValue.showingLandscapeTutorial
            self.showingFilterTutorial = newValue.showingFilterTutorial

            if let selectedAristState = newValue.selectedArtistState {
                favoriteArtists.insertOrRemove(
                    element: selectedAristState.artist.id!,
                    doesBelong: selectedAristState.isFavorite
                )
            }

            selectedGroupSetState?.artistDetailStates.forEach {
                favoriteArtists.insertOrRemove(element: $0.artist.id!, doesBelong: $0.isFavorite)
            }
        }
    }

    var exploreState: ExploreFeature.State {
        get {
            .init(
                artists: exploreArtists,
                event: event,
                stages: stages,
                schedule: schedule,
                selectedArtistPageState: exploreSelectedArtistState,
                favoriteArtists: favoriteArtists
            )
        }

        set {
            self.exploreSelectedArtistState = newValue.selectedArtistPageState
            self.favoriteArtists = newValue.favoriteArtists
        }
    }

    var moreState: MoreFeature.State {
        get {
            .init(
                event: event,
                favoriteArtists: favoriteArtists,
                schedule: schedule,
                artists: artists,
                stages: stages,
                isTestMode: isTestMode,
                notificationsEnabled: notificationsEnabled,
                notificationTimeBeforeSet: notificationTimeBeforeSet,
                showingNavigateToSettingsAlert: notificationsShowingNavigateToSettingsAlert,
                isEventSpecificApplication: isEventSpecificApplication
            )
        }

        set {
            self.notificationsEnabled = newValue.notificationsEnabled
            self.notificationTimeBeforeSet = newValue.notificationTimeBeforeSet
            self.notificationsShowingNavigateToSettingsAlert = newValue.showingNavigateToSettingsAlert
        }
    }
}

extension Set {
    mutating func insertOrRemove(element: Element, doesBelong: Bool) {
        if doesBelong {
            insert(element)
        } else {
            remove(element)
        }
    }
}

public struct TabBar: ReducerProtocol {
    public typealias State = EventFeature.State
    
    public enum Action: BindableAction {
        case binding(_ action: BindingAction<EventFeature.State>)
        case artistListAction(ArtistListFeature.Action)
        case scheduleAction(ScheduleFeature.Action)
        case exploreAction(ExploreFeature.Action)
        case moreAction(MoreFeature.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .artistListAction(.artistDetail(_, .didTapArtistSet(let scheduleCard))), .exploreAction(.artistPage(_, .didTapArtistSet(let scheduleCard))):
                state.selectedTab = .schedule
                return Effect(value: .scheduleAction(.showAndHighlightCard(scheduleCard)))

            case .artistListAction, .scheduleAction, .exploreAction, .moreAction:
                return .none
            }
        }
        
        Scope(state: \.artistListState, action: /Action.artistListAction) {
            ArtistListFeature()
        }
        
        Scope(state: \.scheduleState, action: /Action.scheduleAction) {
            ScheduleFeature()
        }
        
        Scope(state: \.exploreState, action: /Action.exploreAction) {
            ExploreFeature()
        }
        
        Scope(state: \.moreState, action: /Action.moreAction) {
            MoreFeature()
        }
        
    }
}
