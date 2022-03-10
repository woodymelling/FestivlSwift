//
// ManagerEventDashboardDomain.swift
//
//
//  Created by Woody on 3/9/2022.
//

import ComposableArchitecture
import Models

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
        sidebarSelection: SidebarPage?
    ) {
        self.event = event
        self.artists = artists
        self.stages = stages
        self.artistSets = artistSets
        self.sidebarSelection = sidebarSelection
    }

    public private(set) var event: Event
    public private(set) var artists: IdentifiedArrayOf<Artist>
    public private(set) var stages: IdentifiedArrayOf<Stage>
    public private(set) var artistSets: IdentifiedArrayOf<ArtistSet>

    @BindableState public var sidebarSelection: SidebarPage?
}

public enum ManagerEventDashboardAction: BindableAction {
    case binding(_ action: BindingAction<ManagerEventDashboardState>)
    case exitEvent
}

public struct ManagerEventDashboardEnvironment {
    public init() {}
}

public let managerEventDashboardReducer = Reducer<ManagerEventDashboardState, ManagerEventDashboardAction, ManagerEventDashboardEnvironment> { state, action, _ in
    switch action {
    case .binding:
        return .none
    case .exitEvent:
        // Handled at top level
        return .none
    }
}
.binding()
