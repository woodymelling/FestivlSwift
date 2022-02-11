//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation
import FirebaseFirestoreSwift
import Utilities

public typealias EventID = String

public struct Event: Codable, Identifiable {
    public init(
        id: EventID?,
        name: String,
        startDate: Date,
        endDate: Date,
        dayStartsAtNoon: Bool,
        imageURL: URL?
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.dayStartsAtNoon = dayStartsAtNoon
        self.imageURL = imageURL
    }

    @DocumentID public var id: EventID?
    public let name: String
    public let startDate: Date
    public let endDate: Date
    public let dayStartsAtNoon: Bool
    public let imageURL: URL?

    public var festivalDates: [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        var cur = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
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
            id: "16tOy7egIbzF0T9riZYp",
            name: "Testival",
            startDate: Date(),
            endDate: Date(timeInterval: 100000, since: Date()),
            dayStartsAtNoon: true,
            imageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2FB6CCE847-7E71-4AB7-9EE1-3414434EA17F.png?alt=media&token=87dda3ba-377f-48b3-bfbd-30bcc2dbbc6c")
        )
    }
}


