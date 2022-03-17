//
// ManagerEventDashboardDomain.swift
//
//
//  Created by Woody on 3/9/2022.
//

import ComposableArchitecture
import Models
import ManagerArtistsFeature

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

public struct ManagerEventDashboardState: Equatable {
    public init(
        event: Event,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        artistSets: IdentifiedArrayOf<ArtistSet>,
        sidebarSelection: SidebarPage?,
        artistListSelectedArtist: Artist?,
        isShowingAddArtist: Bool
    ) {
        self.event = event
        self.artists = artists
        self.stages = stages
        self.artistSets = artistSets
        self.sidebarSelection = sidebarSelection
        self.artistListSelectedArtist = artistListSelectedArtist
        self.isShowingAddArtist = isShowingAddArtist
    }

    public private(set) var event: Event
    public private(set) var artists: IdentifiedArrayOf<Artist>
    public private(set) var stages: IdentifiedArrayOf<Stage>
    public private(set) var artistSets: IdentifiedArrayOf<ArtistSet>

    @BindableState public var sidebarSelection: SidebarPage?

    // MARK: ArtistList
    public var artistListSelectedArtist: Artist?
    public var isShowingAddArtist: Bool

    var artistsState: ManagerArtistsState {
        get {
            return .init(
                artists: artists,
                selectedArtist: artistListSelectedArtist,
                isShowingAddArtist: isShowingAddArtist
            )
        }
        set {
            self.artists = newValue.artists
            self.artistListSelectedArtist = newValue.selectedArtist
            self.isShowingAddArtist = newValue.isShowingAddArtist
        }
    }
}

public enum ManagerEventDashboardAction: BindableAction {
    case binding(_ action: BindingAction<ManagerEventDashboardState>)
    case artistsAction(ManagerArtistsAction)

    case exitEvent
}

public struct ManagerEventDashboardEnvironment {
    public init() {}
}

public let managerEventDashboardReducer = Reducer.combine(
    Reducer<ManagerEventDashboardState, ManagerEventDashboardAction, ManagerEventDashboardEnvironment> { state, action, _ in
        switch action {
        case .binding:
            return .none
        case .exitEvent:
            // Handled at top level
            return .none
        case .artistsAction:
            return .none
        }
    }
    .binding(),

    managerArtistsReducer.pullback(
        state: \ManagerEventDashboardState.artistsState,
        action: /ManagerEventDashboardAction.artistsAction,
        environment: { _ in .init() }
    )
)


