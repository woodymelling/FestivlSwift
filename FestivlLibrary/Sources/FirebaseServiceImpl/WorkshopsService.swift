//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/28/23.
//

import Models
import FirebaseFirestore
import FirebaseFirestoreSwift
import FestivlDependencies
import Dependencies

struct FirebaseWorkshopDTO: Codable {
    @DocumentID var id: String?
    var name: String?
    var location: String?
    var instructorName: String?
    var description: String?
    var startTime: Date?
    var endTime: Date?
    var imageURL: URL?
    
    static var asWorkshop: (Self) -> Workshop = {
        Workshop(
            id: .init($0.id ?? ""),
            name: $0.name ?? "",
            location: $0.location ?? "",
            instructorName: $0.instructorName ?? "",
            description: $0.description ?? "",
            startTime: $0.startTime ?? .now,
            endTime: $0.endTime ?? .now,
            imageURL: $0.imageURL
        )
    }
    
    init(from workshop: Workshop) {
        self.name = workshop.name
        self.location = workshop.location
        self.instructorName = workshop.instructorName
        self.description = workshop.description
        self.startTime = workshop.startTime
        self.endTime = workshop.endTime
        self.imageURL = workshop.imageURL
    }
}

extension WorkshopsClientDependencyKey: DependencyKey {
    public static var liveValue = WorkshopsClient(
        fetchWorkshops: { eventID in
            FirebaseService.observeQuery(
                db.collection("events").document(eventID.rawValue).collection("workshops").order(by: "name"),
                mapping: FirebaseWorkshopDTO.asWorkshop
            )
        },
        createWorkshop: { eventID, workshop in
            try await FirebaseService.createDocument(
                reference: db.collection("events").document(eventID.rawValue).collection("workshops"),
                data: FirebaseWorkshopDTO(from: workshop)
            )
        }
    )
}
