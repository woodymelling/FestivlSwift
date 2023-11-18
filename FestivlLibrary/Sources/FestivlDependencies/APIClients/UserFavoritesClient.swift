//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/28/22.
//

import Foundation
import Models
import Dependencies
import DependenciesMacros
import XCTestDynamicOverlay
import Utilities
import Combine
import IdentifiedCollections
import UserNotifications
import Tagged

public typealias UserFavorites = Set<Artist.ID>

public extension UserFavorites {
    func contains(_ scheduleItem: ScheduleItem) -> Bool {
        switch scheduleItem.type {
        case .artistSet(let artistID):
            return self.contains(artistID)
        case .groupSet(let artistIDs):
            return artistIDs.contains(where: { self.contains($0)} )
        }
    }
}

// MARK: API
@DependencyClient
public struct UserFavoritesClient {
    public var toggleArtistFavorite: (Artist.ID) -> Void
    public var userFavoritesPublisher: () -> DataStream<UserFavorites> = { Empty().eraseToDataStream() }
    public var updateScheduleData: (Schedule, IdentifiedArrayOf<Artist>, IdentifiedArrayOf<Stage>) -> Void

    public var updateNotificationSettings: (_ notificationsEnabled: Bool, _ beforeSetNotificationTime: Int) -> Void

    public var registerNotificationCategories: () -> Void

    public var notificationsEnabled: () -> Bool = { false }
    public var beforeSetNotificationTime: () -> Int = { 0 }

    public var sendNotificationsNow: () -> Void
}

// MARK: DependencyKey
extension UserFavoritesClient: DependencyKey {
    public static var liveValue: UserFavoritesClient = .init(
        toggleArtistFavorite: UserFavoritesStore.shared.toggleArtistFavorite(artistID:),
        userFavoritesPublisher: UserFavoritesStore.shared.publisher.eraseToDataStream,
        updateScheduleData: UserFavoritesStore.shared.updateScheduleData(schedule:artists:stages:),
        updateNotificationSettings: {
            UserFavoritesStore.shared.updateNotificationSettings(notificationsEnabled: $0, beforeSetNotificationTime: $1)
        } ,
        registerNotificationCategories: UNUserNotificationCenter.registerNotificationCategories,
        notificationsEnabled: {
            print("NOTIFS Getting:", UserFavoritesStore.notificationsEnabled)
            return UserFavoritesStore.notificationsEnabled
            
        },
        beforeSetNotificationTime: { UserFavoritesStore.beforeSetNotificationTime  },
        sendNotificationsNow: { UserFavoritesStore.shared.regenerateNotifications(sendNow: true) }
    )
    
    public static var testValue: UserFavoritesClient = Self()

    public static var previewValue: UserFavoritesClient = .init(
        toggleArtistFavorite: UserFavoritesPreviewStore.shared.toggleArtistFavorite,
        userFavoritesPublisher: UserFavoritesPreviewStore.shared.userFavoritesPublisher,
        updateScheduleData: { _, _, _ in },
        updateNotificationSettings: UserFavoritesStore.shared.updateNotificationSettings,
        registerNotificationCategories: {},
        notificationsEnabled: { UserFavoritesPreviewStore.shared.notificationsEnabled },
        beforeSetNotificationTime: { UserFavoritesPreviewStore.shared.beforeSetNotificationTime },
        sendNotificationsNow: {}
    )
}

public extension DependencyValues {
    var userFavoritesClient: UserFavoritesClient {
        get { self[UserFavoritesClient.self] }
        set { self[UserFavoritesClient.self] = newValue }
    }
}

// - MARK: Live Implementation
private class UserFavoritesStore {
    static var shared = UserFavoritesStore()
    
    @Storage(
        key: "userFavorites",
        defaultValue: .init(),
        transformation: .init(
            get: { Set($0.map { Artist.ID($0)}) },
            set: { (favorites: UserFavorites) in favorites.map { (value: Artist.ID) in value.rawValue }}
        )
    )
    var userFavorites: UserFavorites
    
    var publisher: CurrentValueSubject<UserFavorites, Never> = .init(.init())
    
    var schedule = Schedule(scheduleItems: .init(), dayStartsAtNoon: false, timeZone: NSTimeZone.default)
    var artists: IdentifiedArrayOf<Artist> = []
    var stages: IdentifiedArrayOf<Stage> = []
    
    @Storage(key: "NotificationsEnabled", defaultValue: false)
    static var notificationsEnabled: Bool  {
        didSet {
            print(notificationsEnabled)
        }
    }
    
    @Storage(key: "BeforeSetNotificationTime", defaultValue: 5)
    static var beforeSetNotificationTime: Int
    
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
        Self.notificationsEnabled = notificationsEnabled
        Self.beforeSetNotificationTime = beforeSetNotificationTime
        
        self.regenerateNotifications()
    }
    
    func regenerateNotifications(sendNow: Bool = false) {
        UNUserNotificationCenter.current().regenerateArtistSetNotifications(
            notificationsEnabled: Self.notificationsEnabled,
            favoriteArtists: userFavorites,
            artists: artists,
            stages: stages,
            schedule: schedule,
            sendNow: sendNow,
            minutesTilSet: Self.beforeSetNotificationTime
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
            .flatMap { return schedule[artistID: $0] }
            .forEach { scheduleItem in
                stages[id: scheduleItem.stageID].map {
                    self.createNotificationForSet(
                        scheduleItem,
                        stage: $0,
                        minutesTilSet: minutesTilSet,
                        runNotificationNow: sendNow
                    )
                }
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
