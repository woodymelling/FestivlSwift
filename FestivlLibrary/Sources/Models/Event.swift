//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation
import Tagged
import IdentifiedCollections
import Utilities

public struct Event: Identifiable, Equatable {
    public init(
        id: Tagged<Event, String>,
        name: String,
        startDate: CalendarDate,
        endDate: CalendarDate,
        dayStartsAtNoon: Bool,
        imageURL: URL? = nil,
        siteMapImageURL: URL? = nil,
        contactNumbers: IdentifiedArrayOf<ContactNumber>? = nil,
        address: String? = nil,
        latitude: String? = nil,
        longitude: String? = nil,
        timeZone: TimeZone,
        isTestEvent: Bool = false,
        scheduleIsPublished: Bool = false,
        internalPreviewKey: String? = nil,
        mainEventColor: Color = .systemBlue,
        workshopsColor: Color = .systemGreen
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.dayStartsAtNoon = dayStartsAtNoon
        self.imageURL = imageURL
        self.siteMapImageURL = siteMapImageURL
        self.contactNumbers = contactNumbers
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.timeZone = timeZone
        self.isTestEvent = isTestEvent
        self.scheduleIsPublished = scheduleIsPublished
        self.internalPreviewKey = internalPreviewKey
        self.workshopsColor = workshopsColor
        self.mainEventColor = mainEventColor
    }
    
    public var id: Tagged<Event, String> //
    public var name: String //
    
    public var startDate: CalendarDate
    public var endDate: CalendarDate
    public var timeZone: TimeZone
    
    public var dayStartsAtNoon: Bool
    
    public var imageURL: URL?
    public var siteMapImageURL: URL?
    public var contactNumbers: IdentifiedArrayOf<ContactNumber>?
    
    public var address: String?
    public var latitude: String?
    public var longitude: String?
    
    public var isTestEvent: Bool
    public var scheduleIsPublished: Bool
    public var internalPreviewKey: String?
    
    public var workshopsColor: Color
    public var mainEventColor: Color
    
    public var dateRange: Range<CalendarDate> {
        startDate..<endDate
    }

    public var festivalDates: [CalendarDate] {
        var dates: [CalendarDate] = []
        var cur = startDate
        let end = dayStartsAtNoon ? endDate.adding(days: -1) : endDate
        repeat {
            dates.append(cur)
            cur.day += 1

        } while (cur <= end)

        return dates
    }
}

public extension Event {
    static var previewData: Event {
        Event(
            id: "0",
            name: "Wicked Woods (September 2022)",
            startDate: CalendarDate(year: 2022, month: 9, day: 8),
            endDate: CalendarDate(year: 2022, month: 9, day: 11),
            dayStartsAtNoon: true,
            imageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2FEE6A4163-01DE-4DF4-A9B7-1AC0D8BE6EAA.png?alt=media&token=4b9951c7-bcc6-405a-ba4c-aa90ab35a98d"),
            siteMapImageURL: URL(string: "https://secureservercdn.net/198.71.233.71/88d.74e.myftpupload.com/wp-content/uploads/2022/02/Map_web_version-1244-2.png?time=1662323120"),
            contactNumbers: .init(
                uniqueElements: [
                    .init(
                        title: "Emergency Services",
                        phoneNumber: "5555551234",
                        description: "This will connect you directly with our switchboard, and alert the appropriate services."
                    ),
                    .init(
                        title: "General Information Line",
                        phoneNumber: "5555554321",
                        description: "For general information, questions or concerns, or to report any sanitation issues within the WW grounds, please contact this number."
                    )
            ]),
            address: "3901 Kootenay Hwy, Fairmont Hot Springs, BC V0B 1L1, Canada",
            latitude: "50.36651951040857",
            longitude: "-115.86954803065706",
            timeZone: TimeZone(identifier: "America/Denver")!,
            isTestEvent: false,
            scheduleIsPublished: false,
            mainEventColor: .blue,
            workshopsColor: Color(hex: "F19953")
        )
    }
    
    static var testValues: IdentifiedArrayOf<Event> {
        IdentifiedArray(arrayLiteral:
            Event(
                id: "1",
                name: "Wicked Woods (September 2022)",
                startDate: CalendarDate(year: 2022, month: 9, day: 8),
                endDate: CalendarDate(year: 2022, month: 9, day: 11),
                dayStartsAtNoon: true,
                imageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2FEE6A4163-01DE-4DF4-A9B7-1AC0D8BE6EAA.png?alt=media&token=4b9951c7-bcc6-405a-ba4c-aa90ab35a98d"),
                siteMapImageURL: URL(string: "https://secureservercdn.net/198.71.233.71/88d.74e.myftpupload.com/wp-content/uploads/2022/02/Map_web_version-1244-2.png?time=1662323120"),
                contactNumbers: .init(),
                address: "3901 Kootenay Hwy, Fairmont Hot Springs, BC V0B 1L1, Canada",
                latitude: "50.36651951040857",
                longitude: "-115.86954803065706",
                timeZone: TimeZone(identifier: "America/Denver")!,
                isTestEvent: false,
                scheduleIsPublished: true,
                mainEventColor: .blue,
                workshopsColor: Color(hex: "#d7fff6")
            ),
            Event(
                id: "2",
                name: "Wicked Woods (Spring 2022)",
                startDate: CalendarDate(year: 2022, month: 5, day: 26),
                endDate: CalendarDate(year: 2022, month: 5, day: 28),
                dayStartsAtNoon: true,
                imageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2FDAA28B1F-8634-49ED-B740-435A751FAAC6.png?alt=media&token=3359edfa-99c5-4b8e-bb39-417f6ce0cfe4"),
                siteMapImageURL: URL(string: "https://secureservercdn.net/198.71.233.71/88d.74e.myftpupload.com/wp-content/uploads/2022/02/Map_web_version-1244-2.png?time=1662323120"),
                contactNumbers: .init(),
                address: "3901 Kootenay Hwy, Fairmont Hot Springs, BC V0B 1L1, Canada",
                latitude: "50.36651951040857",
                longitude: "-115.86954803065706",
                timeZone: TimeZone(identifier: "America/Denver")!,
                isTestEvent: false,
                scheduleIsPublished: true,
                mainEventColor: .blue,
                workshopsColor: Color(hex: "#d7fff6")
            ),
            .previewData
        )
    }
}


public struct ContactNumber: Identifiable, Equatable, Codable {
    public var id: String = UUID().uuidString
    public var phoneNumber: String
    public var title: String
    public var description: String

    public init(title: String, phoneNumber: String, description: String) {
        self.title = title
        self.phoneNumber = phoneNumber
        self.description = description
    }
}


import SwiftUI

public struct EventEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Event = Event(
        id: .init(""),
        name: "",
        startDate: .today,
        endDate: .today,
        dayStartsAtNoon: false,
        timeZone: .current,
        isTestEvent: false,
        scheduleIsPublished: false,
        mainEventColor: .blue,
        workshopsColor: Color(hex: "#d7fff6")
    )
}

public extension EnvironmentValues {
    var event: Event {
        get { self[EventEnvironmentKey.self] }
        set { self[EventEnvironmentKey.self] = newValue }
    }
}
