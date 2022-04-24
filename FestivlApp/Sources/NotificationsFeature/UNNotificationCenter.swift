//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/23/22.
//

import Foundation
import UserNotifications
import Models
import ComposableArchitecture

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
        favoriteArtists: Set<ArtistID>,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        schedule: Schedule,
        sendNow: Bool = false,
        minutesTilSet: Int
    ) {
        self.removeAllPendingNotificationRequests()

        print("Regenerating Notifications!")

        guard notificationsEnabled else { return }

        favoriteArtists
            .compactMap { return artists[id: $0] }
            .flatMap {
                return schedule.scheduleItemsForArtist(artist: $0)
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
        content.userInfo = ["SET_ID": set.id as Any, "TIME_TIL_SET": minutesTilSet as Any]

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
