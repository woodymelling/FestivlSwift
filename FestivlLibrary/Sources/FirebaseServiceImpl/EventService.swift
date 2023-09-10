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

        init(event: Event) {
            self.id = event.id.rawValue
            self.name = event.name
            self.startDate = event.startDate.date
            self.endDate = event.endDate.date
            self.dayStartsAtNoon = event.dayStartsAtNoon
            self.imageURL = event.imageURL
            self.siteMapImageURL = event.siteMapImageURL
            self.contactNumbers = event.contactNumbers
            self.address = event.address
            self.latitude = event.latitude
            self.longitude = event.longitude
            self.timeZone = event.timeZone.identifier
            self.isTestEvent = event.isTestEvent
            self.scheduleIsPublished = event.scheduleIsPublished
            self.internalPreviewKey = event.internalPreviewKey
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


extension EventClientKey: DependencyKey {
    public static var liveValue = EventClient(
        getEvents: {
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
        createEvent: { eventData in
            @Dependency(\.organizationID) var organizationID

            var eventData = Event.DTO(event: eventData)
            eventData.id = nil

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
