//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase
import Combine
import ServiceCore
import Models
import IdentifiedCollections

public protocol ArtistServiceProtocol: Service {
    func createArtist(artist: Artist, eventID: String) async throws
    func updateArtist(artist: Artist, eventID: String) async throws

    func artistsPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<Artist>, FestivlError>
    func watchArtist(artist: Artist, eventID: String) throws -> AnyPublisher<Artist, FestivlError>
}

public class ArtistService: ArtistServiceProtocol {
    private let db = Firestore.firestore()

    public func getArtistListRef(eventID: String) -> CollectionReference {
        db.collection("events").document(eventID).collection("artists")
    }

    public static var shared = ArtistService()

    public func createArtist(artist: Artist, eventID: String) async throws {
        try await createDocument(
            reference: getArtistListRef(eventID: eventID),
            data: artist
        )
    }

    public func updateArtist(artist: Artist, eventID: String) async throws {
        try await updateDocument(
            documentReference: getArtistListRef(eventID: eventID).document(artist.ensureIDExists()),
            data: artist
        )
    }

    public func artistsPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<Artist>, FestivlError> {
        observeQuery(getArtistListRef(eventID: eventID).order(by: "name"))
    }

    public func watchArtist(artist: Artist, eventID: String) throws -> AnyPublisher<Artist, FestivlError> {
        let id = try artist.ensureIDExists()
        return observeDocument(getArtistListRef(eventID: eventID).document(id))
    }
}

public struct ArtistMockService: ArtistServiceProtocol {
    public func createArtist(artist: Artist, eventID: String) async throws { }

    public func updateArtist(artist: Artist, eventID: String) async throws { }

    public func artistsPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<Artist>, FestivlError> {
        let testData = Artist.testData
        return Just([
            "Rhythmbox",
            "Abstrakt Sonance",
            "Anti Up",
            "Bonobo",
            "Chuurch",
            "Doc Martin"
        ].map { name in

            Artist(
                id: UUID().uuidString,
                name: name,
                description: testData.description,
                tier: testData.tier,
                imageURL: testData.imageURL,
                soundcloudURL: testData.soundcloudURL,
                websiteURL: testData.websiteURL,
                spotifyURL: testData.spotifyURL
            )
        })
            .map { IdentifiedArray(uniqueElements: $0) }
            .setFailureType(to: FestivlError.self)
            .eraseToAnyPublisher()
    }

    public func watchArtist(artist: Artist, eventID: String) throws -> AnyPublisher<Artist, FestivlError> {
        Just(.testData)
            .setFailureType(to: FestivlError.self)
            .eraseToAnyPublisher()
    }

    public init() { }
    
}


