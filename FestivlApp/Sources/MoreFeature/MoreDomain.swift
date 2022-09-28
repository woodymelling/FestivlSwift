//
// MoreDomain.swift
//
//
//  Created by Woody on 4/22/2022.
//

import ComposableArchitecture
import Models
import NotificationsFeature

public struct MoreFeature: ReducerProtocol {
    public init() {}
    
    public struct State: Equatable {

        let event: Event
        let favoriteArtists: Set<ArtistID>
        let schedule: Schedule
        let artists: IdentifiedArrayOf<Artist>
        let stages: IdentifiedArrayOf<Stage>
        let isTestMode: Bool
        let isEventSpecificApplication: Bool

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
            showingNavigateToSettingsAlert: Bool,
            isEventSpecificApplication: Bool
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
            self.isEventSpecificApplication = isEventSpecificApplication
        }

        var notificationsState: NotificationsFeature.State {
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
    
    public enum Action {
        case notificationsAction(NotificationsFeature.Action)
        case didExitEvent
    }
    
    public var body: some ReducerProtocol<MoreFeature.State, MoreFeature.Action> {
        Scope(state: \.notificationsState, action: /Action.notificationsAction) {
            NotificationsFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .didExitEvent, .notificationsAction:
                return .none
            }
        }
    }
}
