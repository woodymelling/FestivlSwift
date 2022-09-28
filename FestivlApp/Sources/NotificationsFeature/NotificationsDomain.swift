//
// NotificationsDomain.swift
//
//
//  Created by Woody on 4/23/2022.
//

import ComposableArchitecture
import Models
import UserNotifications
import FestivlDependencies

public struct NotificationsFeature: ReducerProtocol {
    
    public init() {}
    
    @Dependency(\.userNotificationCenter) var notificationCenter
    
    public struct State: Equatable {
        public init(
            favoriteArtists: Set<ArtistID>,
            schedule: Schedule,
            artists: IdentifiedArrayOf<Artist>,
            stages: IdentifiedArrayOf<Stage>,
            isTestMode: Bool,
            notificationsEnabled: Bool,
            notificationTimeBeforeSet: Int,
            showingNavigateToSettingsAlert: Bool
        ) {
            self.favoriteArtists = favoriteArtists
            self.schedule = schedule
            self.artists = artists
            self.stages = stages
            self.isTestMode = isTestMode
            self.notificationsEnabled = notificationsEnabled
            self.notificationTimeBeforeSet = notificationTimeBeforeSet
            self.showingNavigateToSettingsAlert = showingNavigateToSettingsAlert
        }

        public let favoriteArtists: Set<ArtistID>
        public let schedule: Schedule
        public let artists: IdentifiedArrayOf<Artist>
        public let stages: IdentifiedArrayOf<Stage>

        public var isTestMode: Bool
        @BindableState public var notificationsEnabled: Bool
        @BindableState public var notificationTimeBeforeSet: Int

        @BindableState public var showingNavigateToSettingsAlert: Bool
    }
    
    public enum Action: BindableAction {
        case binding(_ action: BindingAction<State>)
        case registerForNotifications
        case notifictationsPermitted
        case notificationsDenied
        case regenerateNotifications(sendNow: Bool = false)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.$notificationsEnabled):
                if state.notificationsEnabled {
                    return .task {
                        do {
                            if try await notificationCenter().requestAuthorization(options: [.alert, .sound]) {
                                return .notifictationsPermitted
                            } else {
                                return .notificationsDenied
                            }
                        } catch {
                            print("notifications Error", error)
                            return .notificationsDenied
                        }
                    }
                } else {
                    return Effect(value: .regenerateNotifications())
                }

            case .binding(\.$notificationTimeBeforeSet):
                return Effect(value: .regenerateNotifications())

            case .binding:
                return .none

            case .registerForNotifications:
                UNUserNotificationCenter.registerNotificationCategories()
                return .none

            case .notificationsDenied:
                state.notificationsEnabled = false
                state.showingNavigateToSettingsAlert = true

                return .none

            case .regenerateNotifications(let sendNow):
                notificationCenter().regenerateArtistSetNotifications(
                    notificationsEnabled: state.notificationsEnabled,
                    favoriteArtists: state.favoriteArtists,
                    artists: state.artists,
                    stages: state.stages,
                    schedule: state.schedule,
                    sendNow: sendNow,
                    minutesTilSet: state.notificationTimeBeforeSet
                )
                return .none

            case .notifictationsPermitted:
                return Effect(value: .regenerateNotifications())
            }
        }
    }
}
