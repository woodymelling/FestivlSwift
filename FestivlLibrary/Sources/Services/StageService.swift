//
//  StageService.swift
//  
//
//  Created by Woody on 2/13/22.
//

import Foundation
import ServiceCore
import FirebaseFirestoreSwift
import Firebase
import Models
import IdentifiedCollections
import Combine

public protocol StageServiceProtocol: Service {
    func createStage(stage: Stage, eventID: String) async throws -> Stage
    func updateStage(stage: Stage, eventID: String) async throws
    func updateStageSortOrder(newOrder: IdentifiedArrayOf<Stage>, eventID: String) async throws

    func stagesPublisher(eventID: String) ->  AnyPublisher<IdentifiedArrayOf<Stage>, FestivlError>
    func watchStage(stage: Stage, eventID: String) throws -> AnyPublisher<Stage, FestivlError>
}

public class StageService: StageServiceProtocol {


    private let db = Firestore.firestore()

    private func getStagesRef(eventID: String) -> CollectionReference {
        db.collection("events").document(eventID).collection("stages")
    }

    public static var shared = StageService()

    public func createStage(stage: Stage, eventID: String) async throws -> Stage {
        let document = try await createDocument(
            reference: getStagesRef(eventID: eventID),
            data: stage
        )

        var stage = stage
        stage.id = document.documentID
        return stage
    }

    public func updateStage(stage: Stage, eventID: String) async throws {
        try await updateDocument(
            documentReference: getStagesRef(eventID: eventID).document(stage.ensureIDExists()),
            data: stage
        )
    }

    public func updateStageSortOrder(newOrder: IdentifiedArrayOf<Stage>, eventID: String) async throws {
        let batch = db.batch()

        for (newIndex, stage) in newOrder.enumerated() {
            try batch.updateData(["sortIndex": newIndex], forDocument: getStagesRef(eventID: eventID).document(stage.ensureIDExists()))
        }

        return try await withUnsafeThrowingContinuation { continuation in
            batch.commit { error in
                if let error = error {
                    continuation.resume(throwing: error)
                }

                continuation.resume()
            }
        }
    }

    public func stagesPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<Stage>, FestivlError> {
        observeQuery(getStagesRef(eventID: eventID).order(by: "sortIndex"))
    }

    public func watchStage(stage: Stage, eventID: String) throws -> AnyPublisher<Stage, FestivlError> {
        try observeDocument(getStagesRef(eventID: eventID).document(stage.ensureIDExists()))
    }
}

struct StageMockService: StageServiceProtocol {
    func createStage(stage: Stage, eventID: String) async throws -> Stage {
        var stage = stage
        stage.id = UUID().uuidString
        return stage
    }

    func updateStage(stage: Stage, eventID: String) async throws {}

    func updateStageSortOrder(newOrder: IdentifiedArrayOf<Stage>, eventID: String) async throws {}

    func stagesPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<Stage>, FestivlError> {
        Just(Stage.testValues.asIdentifedArray)
            .setFailureType(to: FestivlError.self)
            .eraseToAnyPublisher()
    }

    func watchStage(stage: Stage, eventID: String) throws -> AnyPublisher<Stage, FestivlError> {
        Just(Stage.testData)
            .setFailureType(to: FestivlError.self)
            .eraseToAnyPublisher()
    }

    
}
