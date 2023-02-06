//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import Foundation

import Foundation
import Combine
import ServiceCore
import Models
import IdentifiedCollections

public protocol ScheduleServiceProtocol: Service {
    func createArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch?) async throws -> ArtistSet
    func updateArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch?) async throws
    func deleteArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch?) async throws

    func createGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch?) async throws -> GroupSet
    func updateGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch?) async throws
    func deleteGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch?) async throws

    func schedulePublisher(eventID: String) -> AnyPublisher<(IdentifiedArrayOf<ArtistSet>, IdentifiedArrayOf<GroupSet>), FestivlError>
}

public extension ScheduleServiceProtocol {
//    func createArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch? = nil ) async throws -> ArtistSet {
//        try await self.createArtistSet(set, eventID: eventID, batch: batch)
//    }
//
//    func updateArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch? = nil) async throws {
//        try await self.updateArtistSet(set, eventID: eventID, batch: batch)
//    }
//
//    func deleteArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch? = nil) async throws {
//        try await self.deleteArtistSet(set, eventID: eventID, batch: batch)
//    }
//
//    func createGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch? = nil) async throws -> GroupSet {
//        try await self.createGroupSet(set, eventID: eventID, batch: batch)
//    }
//
//    func updateGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch? = nil) async throws {
//        try await self.updateGroupSet(set, eventID: eventID, batch: batch)
//    }
//
//    func deleteGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch? = nil) async throws {
//        try await self.deleteGroupSet(set, eventID: eventID, batch: batch)
//    }

}

public class ScheduleService: ScheduleServiceProtocol {
    private let db = Firestore.firestore()
    public static var shared = ScheduleService()

    public func getBatch() -> WriteBatch {
        return db.batch()
    }

    // MARK: Refs
    private func getArtistSetRef(eventID: String) -> CollectionReference {
        db.collection("events")
            .document(eventID)
            .collection("artist_sets")
    }

    private func getGroupSetRef(eventID: String) -> CollectionReference {
        db.collection("events")
            .document(eventID)
            .collection("group_sets")
    }

    // MARK: ArtistSet
    public func createArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch? = nil) async throws -> ArtistSet {
        let document = try await createDocument(
            reference: getArtistSetRef(eventID: eventID),
            data: set,
            batch: batch
        )

        var set = set
        set.id = document.documentID
        return set
    }

    public func updateArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch? = nil) async throws {
        try await updateDocument(
            documentReference: getArtistSetRef(eventID: eventID).document(set.ensureIDExists()),
            data: set,
            batch: batch
        )
    }

    public func deleteArtistSet(_ set: ArtistSet, eventID: String, batch: WriteBatch? = nil) async throws {
        try await deleteDocument(
            documentReference: getArtistSetRef(eventID: eventID).document(set.ensureIDExists()),
            batch: batch
        )
    }

    public func artistSetPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<ArtistSet>, FestivlError> {
        observeQuery(getArtistSetRef(eventID: eventID))
    }

    public func schedulePublisher(eventID: String) -> AnyPublisher<(IdentifiedArrayOf<ArtistSet>, IdentifiedArrayOf<GroupSet>), FestivlError> {

        let artistSetPublisher: AnyPublisher<IdentifiedArrayOf<ArtistSet>, FestivlError> = observeQuery(
            getArtistSetRef(eventID: eventID)
        )

        let groupSetPublisher: AnyPublisher<IdentifiedArrayOf<GroupSet>, FestivlError> = observeQuery(
            getGroupSetRef(eventID: eventID)
        )


        return Publishers.CombineLatest(
            artistSetPublisher,
            groupSetPublisher
        )
        .eraseToAnyPublisher()
    }

    // MARK: GroupSet
    public func createGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch? = nil) async throws -> GroupSet {
        let document = try await createDocument(
            reference: getGroupSetRef(eventID: eventID),
            data: set,
            batch: batch
        )

        var set = set
        set.id = document.documentID
        return set
    }

    public func updateGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch? = nil) async throws {
        try await updateDocument(
            documentReference: getGroupSetRef(eventID: eventID).document(set.ensureIDExists()),
            data: set,
            batch: batch
        )
    }

    public func deleteGroupSet(_ set: GroupSet, eventID: String, batch: WriteBatch? = nil) async throws {
        try await deleteDocument(documentReference: getGroupSetRef(eventID: eventID).document(set.ensureIDExists()))
    }
}
