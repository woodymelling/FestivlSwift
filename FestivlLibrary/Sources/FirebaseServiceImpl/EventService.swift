//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Dependencies
import FestivlDependencies
import FirebaseFirestoreSwift
import Combine
import IdentifiedCollections
import Utilities
import Tagged
import Models
import SwiftUI

extension Event {
    struct DTO: Codable {
        @DocumentID var id: String?
        var name: String
        var startDate: Date
        var endDate: Date
        var dayStartsAtNoon: Bool
        var imageURL: URL?
        var siteMapImageURL: URL?
        var contactNumbers: IdentifiedArrayOf<ContactNumber>?
        var address: String?
        var latitude: String?
        var longitude: String?
        var timeZone: String?
        var isTestEvent: Bool?
        var scheduleIsPublished: Bool?
        var internalPreviewKey: String?

        init(
            id: String? = nil,
            name: String,
            startDate: Date,
            endDate: Date,
            dayStartsAtNoon: Bool,
            imageURL: URL? = nil,
            siteMapImageURL: URL? = nil,
            contactNumbers: IdentifiedArrayOf<ContactNumber>? = nil,
            address: String? = nil,
            latitude: String? = nil,
            longitude: String? = nil,
            timeZone: String? = nil,
            isTestEvent: Bool? = nil,
            scheduleIsPublished: Bool? = nil,
            internalPreviewKey: String? = nil
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
        }

        static var asEvent: (Self) -> Event = {
            
            return Event(
                id: .init($0.id!),
                name: $0.name,
                startDate: CalendarDate(date: $0.startDate),
                endDate: CalendarDate(date: $0.endDate),
                dayStartsAtNoon: $0.dayStartsAtNoon,
                imageURL: $0.imageURL,
                siteMapImageURL: $0.siteMapImageURL,
                contactNumbers: $0.contactNumbers ?? .init(),
                address: $0.address ?? "",
                latitude: $0.latitude ?? "",
                longitude: $0.longitude ?? "",
                timeZone: TimeZone(identifier: $0.timeZone ?? "") ?? NSTimeZone.default, // TODO replace with default timeZone
                isTestEvent: $0.isTestEvent ?? false,
                scheduleIsPublished: $0.scheduleIsPublished ?? true,
                internalPreviewKey: $0.internalPreviewKey
            )
        }
    }

}


extension EventClient: DependencyKey {
    public static var liveValue = EventClient(
        getPublicEvents: {
            FirebaseService.observeQuery(db.collection("events").order(by: "startDate", descending: true), mapping: Event.DTO.asEvent)
        },
        getEvent: {
            @Dependency(\.eventID) var eventID
            return FirebaseService.observeDocument(db.collection("events").document(eventID.rawValue), mapping: Event.DTO.asEvent)
            .eraseToAnyPublisher()
        },
        getMyEvents: {
            @Dependency(\.eventID) var eventID
            return FirebaseService.observeDocument(db.collection("events").document(eventID.rawValue), mapping: Event.DTO.asEvent)
            .eraseToAnyPublisher()
        },
        createEvent: { name, startDate, endDate, dayStartsAtNoon, timeZone, imageURL in
            @Dependency(\.organizationID) var organizationID

            var eventData = Event.DTO(
                name: name,
                startDate: startDate.date,
                endDate: endDate.date,
                dayStartsAtNoon: dayStartsAtNoon
            )

            let response = try await FirebaseService.createDocument(
                reference: db.collection("organizations").document(organizationID.rawValue).collection("events"),
                data: eventData
            )

            return Event.ID(response.documentID)
        },
        editEvent: { _ in
            fatalError("Not Implemented")
        }
    )
}
