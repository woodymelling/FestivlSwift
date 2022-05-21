//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/13/22.
//

import Foundation
import Services
import ServiceCore
import Models
import Combine
import ComposableArchitecture
import Firebase

public protocol PublishableScheduleServiceProtocol: ScheduleServiceProtocol {
    func publishChanges(eventID: EventID) async throws -> Void

}

public struct ManagerSchedule: Equatable {
    public init(artistSets: IdentifiedArrayOf<ArtistSet>, groupSets: IdentifiedArrayOf<GroupSet>) {
        self.artistSets = artistSets
        self.groupSets = groupSets
    }

    var artistSets: IdentifiedArrayOf<ArtistSet>
    var groupSets: IdentifiedArrayOf<GroupSet>
}


private func makeChangesFor(_ changes: [Change], eventID: EventID, batch: WriteBatch) async throws {
    var remoteID: String? = changes.first?.setID
    for change in changes {
        remoteID = try await change.applyChange(eventID: eventID, changedID: remoteID, batch: batch)
    }
}

private enum Change {
    case createArtistSet(ArtistSet)
    case updateArtistSet(ArtistSet)
    case deleteArtistSet(ArtistSet)
    case createGroupSet(GroupSet)
    case updateGroupSet(GroupSet)
    case deleteGroupSet(GroupSet)

    var setID: String {
        let id: String?
        switch self {
        case .createArtistSet(let artistSet):
            id = artistSet.id
        case .updateArtistSet(let artistSet):
            id = artistSet.id
        case .deleteArtistSet(let artistSet):
            id = artistSet.id
        case .createGroupSet(let groupSet):
            id = groupSet.id
        case .updateGroupSet(let groupSet):
            id = groupSet.id
        case .deleteGroupSet(let groupSet):
            id = groupSet.id
        }

        guard let id = id else {
            fatalError("Required ID")
        }
        return id
    }

    // Apply a specific change
    // The changedID is neccesary because creating a set makes a different ID in firebase (dumb)
    func applyChange(eventID: EventID, changedID: String?, batch: WriteBatch) async throws -> String? {
        let scheduleService = ScheduleService.shared
        switch self {
        case .createArtistSet(let artistSet):
            let artistSet = try await scheduleService.createArtistSet(artistSet, eventID: eventID, batch: batch)
            return artistSet.id

        case .updateArtistSet(let artistSet):
            var artistSet = artistSet
            artistSet.id = changedID

            try await scheduleService.updateArtistSet(artistSet, eventID: eventID, batch: batch)

            return artistSet.id

        case .deleteArtistSet(let artistSet):
            var artistSet = artistSet
            artistSet.id = changedID

            try await scheduleService.deleteArtistSet(artistSet, eventID: eventID, batch: batch)
            return artistSet.id

        case .createGroupSet(let groupSet):
            let groupSet = try await scheduleService.createGroupSet(groupSet, eventID: eventID, batch: batch)
            return groupSet.id


        case .updateGroupSet(let groupSet):
            var groupSet = groupSet
            groupSet.id = changedID

            try await scheduleService.updateGroupSet(groupSet, eventID: eventID, batch: batch)
            return groupSet.id

        case .deleteGroupSet(let groupSet):
            var groupSet = groupSet
            groupSet.id = changedID

            try await scheduleService.updateGroupSet(groupSet, eventID: eventID, batch: batch)
            return groupSet.id
        }
    }
}


public class PublishableScheduleService: PublishableScheduleServiceProtocol {

    enum ScheduleServiceError: Error {
        case noSetID
    }

    @Published public var schedule: ManagerSchedule




    private var changes: [String: [Change]] = [:] {
        didSet {
            print("LocalStoreChanges:", changes)
        }
    }

    private func makeChange(_ change: Change) {
        changes[change.setID, default: []]
            .append(change)
    }

    public static var inMemoryStore = PublishableScheduleService(schedule: .init(artistSets: .init(), groupSets: .init()))

    public init(schedule: ManagerSchedule) {
        self.schedule = schedule
    }

    // TODO: Pass around the scheduleService
    public func publishChanges(eventID: EventID) async throws {
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            let batch = ScheduleService.shared.getBatch()
            for elementChanges in changes.values {
                taskGroup.addTask {
                    try! await makeChangesFor(elementChanges, eventID: eventID, batch: batch)
                }
            }

            try await taskGroup.waitForAll()

            try await batch.commit()
        }

        changes = [:]
    }

    public func createArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch?) async throws -> ArtistSet {
        var set = set
        set.id = UUID().uuidString
        schedule.artistSets.append(set)

        makeChange(.createArtistSet(set))
        return set
    }

    public func updateArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch?) async throws {
        guard let id = set.id else { throw ScheduleServiceError.noSetID }

        schedule.artistSets[id: id] = set
        makeChange(.updateArtistSet(set))
    }

    public func deleteArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch?) async throws {
        guard let id = set.id else { throw ScheduleServiceError.noSetID }

        schedule.artistSets.remove(id: id)
        makeChange(.deleteArtistSet(set))
    }

    public func createGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch?) async throws -> GroupSet {
        var set = set
        set.id = UUID().uuidString
        schedule.groupSets.append(set)

        makeChange(.createGroupSet(set))
        return set
    }

    public func updateGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch?) async throws {
        guard let id = set.id else { throw ScheduleServiceError.noSetID }

        schedule.groupSets[id: id] = set

        makeChange(.updateGroupSet(set))

    }

    public func deleteGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch?) async throws {
        guard let id = set.id else { throw ScheduleServiceError.noSetID }

        schedule.groupSets.remove(id: id)
        makeChange(.deleteGroupSet(set))
    }

    public func schedulePublisher(eventID: String) -> AnyPublisher<(IdentifiedArrayOf<ArtistSet>, IdentifiedArrayOf<GroupSet>), FestivlError> {
        return $schedule
            .map {
                ($0.artistSets, $0.groupSets)
            }
            .setFailureType(to: FestivlError.self)
            .eraseToAnyPublisher()
    }
}
