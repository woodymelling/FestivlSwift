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

public protocol EventListServiceProtocol: Service {
    func createEvent(_ event: Event) async throws
    func observeAllEvents() -> AnyPublisher<[Event], FestivlError>
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

    public func observeAllEvents() -> AnyPublisher<[Event], FestivlError> {
        observeQuery(db.collection("events"))
    }
}

public struct EventListPreviewService: EventListServiceProtocol {
    public init() {}
    public func createEvent(_ event: Event) async throws { }

    public func observeAllEvents() -> AnyPublisher<[Event], FestivlError> {
        Just((0...10).map { _ in Event.testData })
            .setFailureType(to: FestivlError.self)
            .eraseToAnyPublisher()
    }


}
