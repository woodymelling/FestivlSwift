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

public protocol ArtistSetServiceProtocol: Service {
    func createArtistSet(_ set: ArtistSet, eventID: String) async throws -> ArtistSet
    func updateArtistSet(_ set: ArtistSet, eventID: String) async throws

    func artistSetPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<ArtistSet>, FestivlError>
}

public class ArtistSetService: ArtistSetServiceProtocol {
    private let db = Firestore.firestore()
    public static var shared = ArtistSetService()

    private func getArtistSetRef(eventID: String) -> CollectionReference {
        db.collection("events")
            .document(eventID)
            .collection("artist_sets")
    }
    

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

    public func artistSetPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<ArtistSet>, FestivlError> {
        observeQuery(getArtistSetRef(eventID: eventID))
    }


}
