//
// NotificationsDomain.swift
//
//
//  Created by Woody on 4/23/2022.
//

import ComposableArchitecture
import Models
import UserNotifications

public struct NotificationsState: Equatable {
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

public enum NotificationsAction: BindableAction {
    case binding(_ action: BindingAction<NotificationsState>)
    case registerForNotifications
    case notifictationsPermitted
    case notificationsDenied
    case regenerateNotifications(sendNow: Bool = false)
}

public struct NotificationsEnvironment {
    var notificationCenter: () -> UNUserNotificationCenter
    public init(notificationCenter: @escaping () -> UNUserNotificationCenter = UNUserNotificationCenter.current) {
        self.notificationCenter = notificationCenter
    }
}

public let notificationsReducer = Reducer<NotificationsState, NotificationsAction, NotificationsEnvironment> { state, action, environment in
    switch action {
    case .binding(\.$notificationsEnabled):
        if state.notificationsEnabled {
            return requestAuthorization(notificationCenter: environment.notificationCenter())
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
        environment.notificationCenter().regenerateArtistSetNotifications(
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
.binding()

private func requestAuthorization(notificationCenter: UNUserNotificationCenter) -> Effect<NotificationsAction, Never> {
    return Effect.task {

        do {
            if try await notificationCenter.requestAuthorization(options: [.alert, .sound]) {
                return .notifictationsPermitted
            } else {
                return .notificationsDenied
            }
        } catch {
            print("notifications Error", error)
            return .notificationsDenied
        }
    }
    .receive(on: DispatchQueue.main)
    .eraseToEffect()
}
