//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/28/22.
//

import Foundation
import Models
import Dependencies
import XCTestDynamicOverlay
import Utilities
import Combine
import IdentifiedCollections
import UserNotifications

public typealias UserFavorites = Set<Artist.ID>

// MARK: API
public struct UserFavoritesClient {
    public let toggleArtistFavorite: (Artist.ID) -> Void
    public let userFavoritesPublisher: () -> DataStream<UserFavorites>
    public let updateScheduleData: (Schedule, IdentifiedArrayOf<Artist>, IdentifiedArrayOf<Stage>) -> Void
    
    public let updateNotificationSettings: (Bool, Int) -> Void
    
    public let registerNotificationCategories: () -> Void
    
    public var notificationsEnabled: Bool
    public var beforeSetNotificationTime: Int
    
    public var sendNotificationsNow: () -> Void
}

// MARK: DependencyKey
public enum UserFavoritesClientKey: DependencyKey {
    public static var liveValue: UserFavoritesClient = .init(
        toggleArtistFavorite: UserFavoritesStore.shared.toggleArtistFavorite(artistID:),
        userFavoritesPublisher: UserFavoritesStore.shared.publisher.eraseToDataStream,
        updateScheduleData: UserFavoritesStore.shared.updateScheduleData(schedule:artists:stages:),
        updateNotificationSettings: UserFavoritesStore.shared.updateNotificationSettings(notificationsEnabled:beforeSetNotificationTime:),
        registerNotificationCategories: UNUserNotificationCenter.registerNotificationCategories,
        notificationsEnabled: UserFavoritesStore.shared.notificationsEnabled,
        beforeSetNotificationTime: UserFavoritesStore.shared.beforeSetNotificationTime,
        sendNotificationsNow: { UserFavoritesStore.shared.regenerateNotifications(sendNow: true) }
    )
    
    public static var testValue: UserFavoritesClient = .init(
        toggleArtistFavorite: unimplemented("UserFavoritesClient.toggleArtistFavorite"),
        userFavoritesPublisher: unimplemented("UserFavoritesClient.userFavoritesPublisher"),
        updateScheduleData: unimplemented("UserFavoritesClient.updateScheduleData"),
        updateNotificationSettings: unimplemented("UserFavoritesClient.updateNotificationsSettings"),
        registerNotificationCategories: unimplemented("UserFavoritesclient.registerNotificationCategories"),
        notificationsEnabled: true,
        beforeSetNotificationTime: 5,
        sendNotificationsNow: unimplemented("UserFavoritesclient.sendNotificationsNow")
    )
    
    public static var previewValue: UserFavoritesClient = .init(
        toggleArtistFavorite: UserFavoritesPreviewStore.shared.toggleArtistFavorite,
        userFavoritesPublisher: UserFavoritesPreviewStore.shared.userFavoritesPublisher,
        updateScheduleData: { _, _, _ in },
        updateNotificationSettings: UserFavoritesStore.shared.updateNotificationSettings,
        registerNotificationCategories: {},
        notificationsEnabled: UserFavoritesPreviewStore.shared.notificationsEnabled,
        beforeSetNotificationTime: UserFavoritesPreviewStore.shared.beforeSetNotificationTime,
        sendNotificationsNow: {}
    )
}

public extension DependencyValues {
    var userFavoritesClient: UserFavoritesClient {
        get { self[UserFavoritesClientKey.self] }
        set { self[UserFavoritesClientKey.self] = newValue }
    }
}

// - MARK: Live Implementation
private class UserFavoritesStore {
    static var shared = UserFavoritesStore()
    
    @Storage(
        key: "userFavorites",
        defaultValue: .init(),
        transformation: .init(
            get: { Set($0.map { Artist.ID($0)})},
            set: { (favorites: UserFavorites) in favorites.map { (value: Artist.ID) in value.rawValue }}
        )
    )
    var userFavorites: UserFavorites
    
    var publisher: CurrentValueSubject<UserFavorites, Never> = .init(.init())
    
    var schedule = Schedule(scheduleItems: .init(), dayStartsAtNoon: false, timeZone: NSTimeZone.default)
    var artists: IdentifiedArrayOf<Artist> = []
    var stages: IdentifiedArrayOf<Stage> = []
    
    @Storage(key: "NotificationsEnabled", defaultValue: false)
    var notificationsEnabled: Bool
    
    @Storage(key: "BeforeSetNotificationTime", defaultValue: 5)
    var beforeSetNotificationTime: Int
    
    init() {
        self.publisher = .init(userFavorites)
    }
    
    func toggleArtistFavorite(artistID: Artist.ID) -> Void {
        if userFavorites.contains(artistID) {
            userFavorites.remove(artistID)
        } else {
            userFavorites.insert(artistID)
        }
        
        publisher.send(userFavorites)
        
        self.regenerateNotifications()
    }
    
    func updateScheduleData(schedule: Schedule, artists: IdentifiedArrayOf<Artist>, stages: IdentifiedArrayOf<Stage>) {
        self.schedule = schedule
        self.stages = stages
        self.artists = artists
        
        self.regenerateNotifications()
    }
    
    func updateNotificationSettings(notificationsEnabled: Bool, beforeSetNotificationTime: Int) {
        self.notificationsEnabled = notificationsEnabled
        self.beforeSetNotificationTime = beforeSetNotificationTime
        
        self.regenerateNotifications()
    }
    
    func regenerateNotifications(sendNow: Bool = false) {
        UNUserNotificationCenter.current().regenerateArtistSetNotifications(
            notificationsEnabled: notificationsEnabled,
            favoriteArtists: userFavorites,
            artists: artists,
            stages: stages,
            schedule: schedule,
            sendNow: sendNow,
            minutesTilSet: beforeSetNotificationTime
        )
    }
}

// MARK: User Notification Generation
extension UNUserNotificationCenter {

    static func registerNotificationCategories() {
        let navigateToSetAction = UNNotificationAction(identifier: "GO_TO_SET_ACTION", title: "Go to set", options: .foreground)

        let artistSetUpcomingCategory = UNNotificationCategory(
            identifier: "UPCOMING_SET",
            actions: [navigateToSetAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([artistSetUpcomingCategory])
    }

    func regenerateArtistSetNotifications(
        notificationsEnabled: Bool,
        favoriteArtists: Set<Artist.ID>,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        schedule: Schedule,
        sendNow: Bool = false,
        minutesTilSet: Int
    ) {
        self.removeAllPendingNotificationRequests()
        guard notificationsEnabled else { return }
        
        

        favoriteArtists
            .flatMap {
                return schedule[artistID: $0]
            }
            .forEach {
                guard let stage = stages[id: $0.stageID] else { return }
                self.createNotificationForSet($0, stage: stage, minutesTilSet: minutesTilSet, runNotificationNow: sendNow)
            }
    }

    func createNotificationForSet(_ set: ScheduleItem, stage: Stage, minutesTilSet: Int, runNotificationNow: Bool) {
        //        let minutesBeforeSet = minutesTilSet ?? UserDefaults.standard[.notifyFavoritesMinutesBefore, default: 15]
        let content = UNMutableNotificationContent()

        if minutesTilSet > 0 {
            content.title = "\(set.title) starting soon!"
            content.body = "\(set.title) is starting in \(minutesTilSet) mins at the \(stage.name)!"
        } else if  minutesTilSet < 0 {
            content.title = "\(set.title) already started!"
            content.body = "\(set.title) started \(-minutesTilSet) mins ago at the \(stage.name)"
        } else {
            content.title = "\(set.title) is starting now!"
            content.body = "\(set.title) is starting right now at the \(stage.name)"
        }

        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "UPCOMING_SET"
        content.userInfo = ["SET_ID": set.id.rawValue, "TIME_TIL_SET": minutesTilSet as Any]

        let trigger: UNNotificationTrigger

        if runNotificationNow {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        } else {

            let calendar = Calendar.autoupdatingCurrent

            let alertTime = calendar.date(byAdding: .minute, value: -minutesTilSet, to: set.startTime)
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: alertTime!)

            print("Generating alert for \(set.title) at \(alertTime!)")

            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        }

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        self.add(request)
    }
}


// MARK: Preview Implementation
private class UserFavoritesPreviewStore {
    static var shared = UserFavoritesPreviewStore()
    
    var userFavorites: UserFavorites = .init()
    var notificationsEnabled: Bool = false
    var beforeSetNotificationTime: Int = 5
    
    func toggleArtistFavorite(artistID: Artist.ID) -> Void {
        if userFavorites.contains(artistID) {
            userFavorites.remove(artistID)
        } else {
            userFavorites.insert(artistID)
        }
    }
    
    func userFavoritesPublisher() -> DataStream<Set<Artist.ID>> {
        Just(userFavorites).eraseToDataStream()
    }
    
    func updateScheduleData(schedule: Schedule, artists: IdentifiedArrayOf<Artist>, stages: IdentifiedArrayOf<Stage>) {
        
    }
    
    func updateNotificationSettings(notificationsEnabled: Bool, beforeSetNotificationTime: Int) {
        self.notificationsEnabled = notificationsEnabled
        self.beforeSetNotificationTime = beforeSetNotificationTime
    }
    
    
}


public extension ScheduleItem {
    func isIncludedInFavorites(userFavorites: UserFavorites) -> Bool {
        switch self.type {
        case .artistSet(let artistID):
            return userFavorites.contains(artistID)
            
        case .groupSet(let artistIDs):
            return artistIDs.contains { artistID in
                userFavorites.contains(artistID)
            }
        }
    }
}
