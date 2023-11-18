//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import Foundation
import Models
import FirebaseFirestoreSwift
import FestivlDependencies
import Dependencies
import Combine
import IdentifiedCollections

struct FirebaseArtistSetDTO: Codable, Identifiable {

    @DocumentID var id: String?
    var artistID: String
    var artistName: String
    var stageID: String
    var startTime: Date
    var endTime: Date
    
    var asScheduleItem: ScheduleItem {
        return ScheduleItem(
            id: .init(self.id ?? ""),
            stageID: .init(stageID),
            startTime: self.startTime,
            endTime: self.endTime,
            title: self.artistName,
            type: .artistSet(.init(self.artistID))
        )
    }
}

struct FirebaseGroupSetDTO: Codable, Identifiable {
    @DocumentID var id: String?
    
    var name: String
    var artistIDs: [String]
    var artistNames: [String]
    var stageID: String
    var startTime: Date
    var endTime: Date
    
    var asScheduleItem: ScheduleItem {
        return ScheduleItem(
            id: .init(self.id ?? ""),
            stageID: .init(self.stageID),
            startTime: self.startTime,
            endTime: self.endTime,
            title: self.name,
            subtext: self.artistNames.joined(separator: ", "),
            type: .groupSet(self.artistIDs.map { .init($0) })
        )
    }
}

private class ScheduleService {
    static var shared: ScheduleService = .init()

    @Published var schedule: Schedule = .init(scheduleItems: [], dayStartsAtNoon: false, timeZone: NSTimeZone.default)
    
    var cancellable: (Event.ID, AnyCancellable)?
    
    
    func getSchedulePublisher(eventID: Event.ID) -> DataStream<Schedule> {
        if let cancellable, cancellable.0 == eventID {
            return $schedule.setFailureType(to: FestivlError.self).eraseToAnyPublisher()
        }
        
        let artistSetsPublisher: FirebaseCollectionPublisher<FirebaseArtistSetDTO> = FirebaseService.observeQuery(
            db.collection("events").document(eventID.rawValue).collection("artist_sets")
        )
        
        let groupSetsPublisher: FirebaseCollectionPublisher<FirebaseGroupSetDTO> = FirebaseService.observeQuery(
            db.collection("events").document(eventID.rawValue).collection("group_sets")
        )
        
        let eventPublisher = FirebaseService.observeDocument(
            db.collection("events").document(eventID.rawValue),
            mapping: Event.DTO.asEvent
        )
        
        @Dependency(\.stageClient) var stageClient
        @Dependency(\.userFavoritesClient) var userFavoritesClient
        
        cancellable = (
            eventID,
            Publishers.CombineLatest3(
                artistSetsPublisher,
                groupSetsPublisher,
                eventPublisher
            )
            .map { artistSets, groupSets, event in
                Schedule(
                    scheduleItems: IdentifiedArray(uniqueElements:
                        artistSets.map { $0.asScheduleItem } + groupSets.map { $0.asScheduleItem }
                    ),
                    dayStartsAtNoon: event.dayStartsAtNoon,
                    timeZone: event.timeZone
                )
            }
            .sink { _ in } receiveValue: {
                self.schedule = $0
            }
       )
            
        return $schedule
            .setFailureType(to: FestivlError.self)
            .share()
            .eraseToAnyPublisher()
    }
    
}


extension ScheduleClient: DependencyKey {
    public static var liveValue = ScheduleClient(
        getSchedule: {
            @Dependency(\.eventID) var eventID
            
            return ScheduleService.shared.getSchedulePublisher(eventID: eventID)
        }
    )
}
