//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation
import Combine
import ServiceCore
import Models
import IdentifiedCollections
import ComposableArchitecture
import Utilities

public protocol ArtistServiceProtocol: Service {
    func createArtist(artist: Artist, eventID: String) async throws -> Artist
    func updateArtist(artist: Artist, eventID: String) async throws
    func deleteArtist(artist: Artist, eventID: String) async throws

    func artistsPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<Artist>, FestivlError>
    func watchArtist(artist: Artist, eventID: String) throws -> AnyPublisher<Artist, FestivlError>
}

public class ArtistService: ArtistServiceProtocol {
    private let db = Firestore.firestore()

    public func getArtistListRef(eventID: String) -> CollectionReference {
        db.collection("events").document(eventID).collection("artists")
    }

    public static var shared = ArtistService()

    public func createArtist(artist: Artist, eventID: String) async throws -> Artist {
        let document = try await createDocument(
            reference: getArtistListRef(eventID: eventID),
            data: artist
        )
        
        var artist = artist
        artist.id = document.documentID
        return artist
    }

    public func updateArtist(artist: Artist, eventID: String) async throws {
        try await updateDocument(
            documentReference: getArtistListRef(eventID: eventID).document(artist.ensureIDExists()),
            data: artist
        )
    }

    public func deleteArtist(artist: Artist, eventID: String) async throws {
        try await deleteDocument(
            documentReference: getArtistListRef(eventID: eventID).document(artist.ensureIDExists())
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
    public func createArtist(artist: Artist, eventID: String) async throws -> Artist {
        var artist = artist
        artist.id = UUID().uuidString
        
        return artist
    }

    public func updateArtist(artist: Artist, eventID: String) async throws { }

    public func deleteArtist(artist: Artist, eventID: String) async throws { }

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


public struct ArtistClient {
    public var getArtists: (EventID) -> FestivlAsyncSequence<IdentifiedArrayOf<Artist>,  FestivlError>
    public var getArtist: (Artist, EventID) throws -> FestivlAsyncSequence<Artist, FestivlError>
}

public extension ArtistClient {
    static var live = ArtistClient(
        getArtists: { ArtistService.shared.artistsPublisher(eventID: $0).values } ,
        getArtist: { try ArtistService.shared.watchArtist(artist: $0, eventID: $1).values }
    )
    
    static var test = ArtistClient(
        getArtists: { ArtistMockService().artistsPublisher(eventID: $0).values },
        getArtist: { try ArtistMockService().watchArtist(artist: $0, eventID: $1).values }
    )
}

public enum ArtistClientKey: DependencyKey {
    public static var liveValue = ArtistClient.live
    public static var previewValue = ArtistClient.test
    public static var testValue = ArtistClient.test
}

public extension DependencyValues {
    var artistsClient: ArtistClient {
        get { self[ArtistClientKey.self] }
        set { self[ArtistClientKey.self] = newValue }
    }
}

public typealias FestivlAsyncSequence<Value, ErrorType: Error> = AsyncThrowingPublisher<AnyPublisher<Value, ErrorType>>
