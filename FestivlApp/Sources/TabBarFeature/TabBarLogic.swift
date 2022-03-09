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


public enum Tab {
    case schedule, artists, explore, settings
}

public struct TabBarState: Equatable {
    public init(
        event: Event,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        artistSets: IdentifiedArrayOf<ArtistSet>,
        selectedTab: Tab,
        artistsListSearchText: String,
        scheduleSelectedStage: Stage,
        scheduleZoomAmount: CGFloat,
        scheduleSelectedDate: Date,
        scheduleScrollAmount: CGPoint
    ) {
        self.event = event
        self.artists = artists
        self.stages = stages
        self.artistSets = artistSets
        self.selectedTab = selectedTab
        self.artistsListSearchText = artistsListSearchText
        self.scheduleSelectedStage = scheduleSelectedStage
        self.scheduleZoomAmount = scheduleZoomAmount
        self.scheduleSelectedDate = scheduleSelectedDate
        self.scheduleScrollAmount = scheduleScrollAmount
    }

    public private(set) var event: Event
    public private(set) var artists: IdentifiedArrayOf<Artist>
    public private(set) var stages: IdentifiedArrayOf<Stage>
    public private(set) var artistSets: IdentifiedArrayOf<ArtistSet>

    @BindableState public var selectedTab: Tab

    // ArtistState lifted state
    public private(set) var artistsListSearchText: String

    // ScheduleState lifted state
    public private(set) var scheduleSelectedStage: Stage
    public private(set) var scheduleZoomAmount: CGFloat
    public private(set) var scheduleSelectedDate: Date
    public private(set) var scheduleScrollAmount: CGPoint
    
    var artistListState: ArtistListState {
        get {
            .init(
                event: event,
                artists: artists,
                stages: stages,
                artistSets: artistSets,
                searchText: artistsListSearchText
            )
        }

        set {
            self.event = newValue.event
            self.artists = IdentifiedArray(uniqueElements: newValue.artistStates.map { $0.artist })
            self.artistsListSearchText = newValue.searchText
        }
    }

    var scheduleState: ScheduleState {
        get {
            .init(
                stages: stages,
                artistSets: artistSets,
                selectedStage: scheduleSelectedStage,
                event: event,
                zoomAmount: scheduleZoomAmount,
                selectedDate: scheduleSelectedDate,
                scrollAmount: scheduleScrollAmount
            )
        }

        set {
            self.stages = newValue.stages
            self.artistSets = newValue.artistSets
            self.scheduleSelectedStage = newValue.selectedStage
            self.event = newValue.event
            self.scheduleZoomAmount = newValue.zoomAmount
            self.scheduleSelectedDate = newValue.selectedDate
            self.scheduleScrollAmount = newValue.scrollAmount
        }
    }
}

public enum TabBarAction: BindableAction {
    case binding(_ action: BindingAction<TabBarState>)
    case artistListAction(ArtistListAction)
    case scheduleAction(ScheduleAction)
}

public struct TabBarEnvironment {
    public init() { }
}

public let tabBarReducer = Reducer.combine(
    Reducer<TabBarState, TabBarAction, TabBarEnvironment> { state, action, _ in
        switch action {
        case .binding:
            return .none
        case .artistListAction, .scheduleAction:
            return .none
        }
    }
    .binding(),

    artistListReducer.pullback(
        state: \TabBarState.artistListState,
        action: /TabBarAction.artistListAction,
        environment: { (_: TabBarEnvironment) in ArtistListEnvironment() }
    ),

    scheduleReducer.pullback(
        state: \TabBarState.scheduleState,
        action: /TabBarAction.scheduleAction,
        environment: { _ in ScheduleEnvironment() })
)
