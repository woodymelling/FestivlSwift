//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import Foundation

import Foundation
import FirebaseFirestoreSwift
import Firebase
import Combine
import ServiceCore
import Models
import IdentifiedCollections

public protocol ScheduleServiceProtocol: Service {
    func createArtistSet(_ set: ArtistSet, eventID: String) async throws -> ArtistSet
    func updateArtistSet(_ set: ArtistSet, eventID: String) async throws
    func deleteArtistSet(_ set: ArtistSet, eventID: String) async throws

    func createGroupSet(_ set: GroupSet, eventID: String) async throws -> GroupSet
    func updateGroupSet(_ set: GroupSet, eventID: String) async throws
    func deleteGroupSet(_ set: GroupSet, eventID: String) async throws

    func schedulePublisher(eventID: String) -> AnyPublisher<(IdentifiedArrayOf<ArtistSet>, IdentifiedArrayOf<GroupSet>), FestivlError>
}

public class ScheduleService: ScheduleServiceProtocol {
    private let db = Firestore.firestore()
    public static var shared = ScheduleService()

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
    public func createArtistSet(_ set: ArtistSet, eventID: String) async throws -> ArtistSet {
        let document = try await createDocument(
            reference: getArtistSetRef(eventID: eventID),
            data: set
        )

        var set = set
        set.id = document.documentID
        return set
    }

    public func updateArtistSet(_ set: ArtistSet, eventID: String) async throws {
        try await updateDocument(
            documentReference: getArtistSetRef(eventID: eventID).document(set.ensureIDExists()),
            data: set
        )
    }

    public func deleteArtistSet(_ set: ArtistSet, eventID: String) async throws {
        try await deleteDocument(documentReference: getArtistSetRef(eventID: eventID).document(set.ensureIDExists()))
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
    public func createGroupSet(_ set: GroupSet, eventID: String) async throws -> GroupSet {
        let document = try await createDocument(
            reference: getGroupSetRef(eventID: eventID),
            data: set
        )

        var set = set
        set.id = document.documentID
        return set
    }

    public func updateGroupSet(_ set: GroupSet, eventID: String) async throws {
        try await updateDocument(
            documentReference: getGroupSetRef(eventID: eventID).document(set.ensureIDExists()),
            data: set
        )
    }

    public func deleteGroupSet(_ set: GroupSet, eventID: String) async throws {
        try await deleteDocument(documentReference: getGroupSetRef(eventID: eventID).document(set.ensureIDExists()))
    }
}
