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
        var workshopsColorString: String?
        var mainEventColorString: String?
        
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
                internalPreviewKey: $0.internalPreviewKey,
                mainEventColor: $0.mainEventColorString.map { Color(hex: $0) } ?? .blue,
                workshopsColor: $0.workshopsColorString.map { Color(hex: $0) } ?? .orange
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
        createEvent: { _ in
            fatalError("Not Implemented")
        },
        editEvent: { _ in
            fatalError("Not Implemented")
        }
    )
}
