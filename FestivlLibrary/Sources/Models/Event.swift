//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation
import FirebaseFirestoreSwift
import Utilities
import ComposableArchitecture

public typealias EventID = String

public struct Event: Codable, SettableIdentifiable {
    public init(
        id: EventID?,
        name: String,
        startDate: Date,
        endDate: Date,
        dayStartsAtNoon: Bool,
        imageURL: URL?,
        siteMapImageURL: URL?,
        contactNumbers: IdentifiedArrayOf<ContactNumber>,
        address: String,
        timeZone: String
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.dayStartsAtNoon = dayStartsAtNoon
        self.imageURL = imageURL
        self.contactNumbers = contactNumbers
        self.address = address
        self.timeZone = timeZone
    }

    @DocumentID public var id: EventID?
    public var name: String
    public var startDate: Date
    public var endDate: Date
    public var dayStartsAtNoon: Bool
    public var imageURL: URL?
    public var siteMapImageURL: URL?
    public var contactNumbers: IdentifiedArrayOf<ContactNumber>?
    public var address: String?
    public var timeZone: String?

    public var festivalDates: [Date] {
        var dates: [Date] = []
        var cur = startDate.startOfDay(dayStartsAtNoon: dayStartsAtNoon)
        let end = endDate.startOfDay(dayStartsAtNoon: dayStartsAtNoon)
        repeat {
            dates.append(cur)
            cur += 1.days

        } while (cur <= end)

        return dates

    }
}

extension Event: Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs._id == rhs._id
    }
}

public extension Event {
    static var testData: Event {
        Event(
            id: UUID().uuidString,
            name: "Testival",
            startDate: Date(),
            endDate: Date(timeInterval: 100000, since: Date()),
            dayStartsAtNoon: true,
            imageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2FB6CCE847-7E71-4AB7-9EE1-3414434EA17F.png?alt=media&token=87dda3ba-377f-48b3-bfbd-30bcc2dbbc6c"),
            siteMapImageURL: nil,
            contactNumbers: .init(),
            address: "",
            timeZone: ""
        )
    }
}


public struct ContactNumber: Identifiable, Equatable, Codable {
    @DocumentID public var id: String?
    public var phoneNumber: String
    public var description: String

    public init(phoneNumber: String, description: String) {
        self.phoneNumber = phoneNumber
        self.description = description
    }
}


