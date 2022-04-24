//
// MoreDomain.swift
//
//
//  Created by Woody on 4/22/2022.
//

import ComposableArchitecture
import Models
import NotificationsFeature

public struct MoreState: Equatable {

    let event: Event
    let favoriteArtists: Set<ArtistID>
    let schedule: Schedule
    let artists: IdentifiedArrayOf<Artist>
    let stages: IdentifiedArrayOf<Stage>
    let isTestMode: Bool

    public var notificationsEnabled: Bool
    public var notificationTimeBeforeSet: Int
    public var showingNavigateToSettingsAlert: Bool

    public init(
        event: Event,
        favoriteArtists: Set<ArtistID>,
        schedule: Schedule,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        isTestMode: Bool,
        notificationsEnabled: Bool,
        notificationTimeBeforeSet: Int,
        showingNavigateToSettingsAlert: Bool
    ) {
        self.event = event
        self.favoriteArtists = favoriteArtists
        self.schedule = schedule
        self.artists = artists
        self.stages = stages
        self.isTestMode = isTestMode
        self.notificationsEnabled = notificationsEnabled
        self.notificationTimeBeforeSet = notificationTimeBeforeSet
        self.showingNavigateToSettingsAlert = showingNavigateToSettingsAlert
    }

    var notificationsState: NotificationsState {
        get {
            .init(
                favoriteArtists: favoriteArtists,
                schedule: schedule,
                artists: artists,
                stages: stages,
                isTestMode: isTestMode,
                notificationsEnabled: notificationsEnabled,
                notificationTimeBeforeSet: notificationTimeBeforeSet,
                showingNavigateToSettingsAlert: showingNavigateToSettingsAlert
            )
        }

        set {
            self.notificationsEnabled = newValue.notificationsEnabled
            self.notificationTimeBeforeSet = newValue.notificationTimeBeforeSet
            self.showingNavigateToSettingsAlert = newValue.showingNavigateToSettingsAlert
        }
    }
}

public enum MoreAction {
    case notificationsAction(NotificationsAction)
}

public struct MoreEnvironment {
    public init() {}
}

public let moreReducer = Reducer<MoreState, MoreAction, MoreEnvironment>.combine(
    notificationsReducer.pullback(
        state: \.notificationsState,
        action: /MoreAction.notificationsAction,
        environment: { _ in .init() }
    ),

    Reducer { state, action, _ in
        return .none
    }
)
