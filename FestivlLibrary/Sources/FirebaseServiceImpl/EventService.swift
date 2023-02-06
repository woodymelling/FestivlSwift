//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Dependencies
import FestivlDependencies
import FirebaseFirestoreSwift
import FirebaseFirestore
import Combine
import IdentifiedCollections
import Utilities
import Tagged
import Models

struct EventDTO: Codable {
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
    
    static var asEvent: (Self) -> Event = {
        Event(
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
            timeZone: $0.timeZone ?? "", // TODO replace with default timeZone
            isTestEvent: $0.isTestEvent ?? false
        )
    }
}


extension EventClientKey: DependencyKey {
    public static var liveValue = EventClient(
        getEvents: {
            FirebaseService.observeQuery(db.collection("events"), mapping: EventDTO.asEvent)
        },
        getEvent: {
            FirebaseService.observeDocument(db.collection("events").document($0.rawValue), mapping: EventDTO.asEvent)
        }
    )
}
