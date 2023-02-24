//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import Models
import FirebaseFirestoreSwift
import FirebaseFirestore
import FestivlDependencies
import Dependencies
import Combine

public struct FirebaseArtistSetDTO: Codable {

    @DocumentID var id: String?
    var artistID: String
    var artistName: String
    var stageID: String
    var startTime: Date
    var endTime: Date
    
    static var asScheduleItem: (Self) -> ScheduleItem = {
        ScheduleItem(
            id: .init($0.id ?? ""),
            stageID: .init($0.stageID),
            startTime: $0.startTime,
            endTime: $0.endTime,
            title: $0.artistName,
            type: .artistSet(.init($0.artistID))
        )
    }
}

public struct FirebaseGroupSetDTO: Codable {
    @DocumentID var id: String?
    
    var name: String
    var artistIDs: [String]
    var artistNames: [String]
    var stageID: String
    var startTime: Date
    var endTime: Date
    
    static var asScheduleItem: (Self) -> ScheduleItem = {
        ScheduleItem(
            id: .init($0.id ?? ""),
            stageID: .init($0.stageID),
            startTime: $0.startTime,
            endTime: $0.endTime,
            title: $0.name,
            subtext: $0.artistNames.joined(separator: ", "),
            type: .groupSet($0.artistIDs.map { .init($0) })
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
        
        let artistSetsPublisher = FirebaseService.observeQuery(
            db.collection("events").document(eventID.rawValue).collection("artist_sets"),
            mapping: FirebaseArtistSetDTO.asScheduleItem
        )
        
        let groupSetsPublisher = FirebaseService.observeQuery(
            db.collection("events").document(eventID.rawValue).collection("group_sets"),
            mapping: FirebaseGroupSetDTO.asScheduleItem
        )
        
        let eventPublisher = FirebaseService.observeDocument(
            db.collection("events").document(eventID.rawValue),
            mapping: EventDTO.asEvent
        )
        
        cancellable = (eventID, Publishers.CombineLatest3(artistSetsPublisher, groupSetsPublisher, eventPublisher)
            .map { artistSets, groupSets, event in
                Schedule(
                    scheduleItems: Set(artistSets + groupSets),
                    dayStartsAtNoon: event.dayStartsAtNoon,
                    timeZone: event.timeZone
                )
            }
            .sink { _ in } receiveValue: {
                self.schedule = $0
            }
       )
            
        return $schedule.setFailureType(to: FestivlError.self).eraseToAnyPublisher()
    }
    
}


extension ScheduleClientKey: DependencyKey {
    public static var liveValue = ScheduleClient(
        getSchedule: { eventID in
            ScheduleService.shared.getSchedulePublisher(eventID: eventID)
        }
    )
}
