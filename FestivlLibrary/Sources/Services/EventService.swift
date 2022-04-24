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
    func createEvent(_ event: Event) async throws -> Event
    func updateEvent(newData event: Event) async throws

    func observeEvent(eventID: EventID) -> AnyPublisher<Event, FestivlError>
    func observeAllEvents() -> AnyPublisher<IdentifiedArrayOf<Event>, FestivlError>
}

public class EventListService: EventListServiceProtocol {


    private let db = Firestore.firestore()

    public static var shared = EventListService()

    public func createEvent(_ event: Event) async throws -> Event {
        let document = try await createDocument(
            reference: db.collection("events"),
            data: event
        )

        var event = event
        event.id = document.documentID
        return event
    }

    public func updateEvent(newData event: Event) async throws {
        try await updateDocument(
            documentReference: db.collection("events").document(event.ensureIDExists()),
            data: event
        )
    }

    public func observeEvent(eventID: EventID) -> AnyPublisher<Event, FestivlError> {
        observeDocument(db.collection("events").document(eventID))
    }

    public func observeAllEvents() -> AnyPublisher<IdentifiedArrayOf<Event>, FestivlError> {
        observeQuery(db.collection("events"))
    }
}

public struct EventListMockService: EventListServiceProtocol {


    public init() {}
    public func createEvent(_ event: Event) async throws -> Event { return event }
    public func updateEvent(newData event: Event) async throws { }

    public func observeAllEvents() -> AnyPublisher<IdentifiedArrayOf<Event>, FestivlError> {
        Just((0...10).map { _ in Event.testData })
            .map { IdentifiedArray(uniqueElements: $0) }
            .setFailureType(to: FestivlError.self)
            .eraseToAnyPublisher()
    }

    public func observeEvent(eventID: EventID) -> AnyPublisher<Event, FestivlError> {
        Just(Event.testData)
            .setFailureType(to: FestivlError.self)
            .eraseToAnyPublisher()
    }
}
