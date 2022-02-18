//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Combine
import FirebaseFirestoreSwift
import Firebase
import ServiceCore
import Models
import IdentifiedCollections

public protocol EventListServiceProtocol: Service {
    func createEvent(_ event: Event) async throws
    func observeAllEvents() -> AnyPublisher<IdentifiedArrayOf<Event>, FestivlError>
}

public class EventListService: EventListServiceProtocol {
    private let db = Firestore.firestore()

    public static var shared = EventListService()

    public func createEvent(_ event: Event) async throws {
        try await createDocument(
            reference: db.collection("events"),
            data: event
        )
    }

    public func observeAllEvents() -> AnyPublisher<IdentifiedArrayOf<Event>, FestivlError> {
        observeQuery(db.collection("events"))
    }
}

public struct EventListMockService: EventListServiceProtocol {
    public init() {}
    public func createEvent(_ event: Event) async throws { }

    public func observeAllEvents() -> AnyPublisher<IdentifiedArrayOf<Event>, FestivlError> {
        Just((0...10).map { _ in Event.testData })
            .map { IdentifiedArray(uniqueElements: $0) }
            .setFailureType(to: FestivlError.self)
            .eraseToAnyPublisher()
    }


}
