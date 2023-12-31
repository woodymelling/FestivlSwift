//
//  StageService.swift
//  
//
//  Created by Woody on 2/13/22.
//


import Models
import Foundation
import FirebaseFirestoreSwift
import FestivlDependencies
import Dependencies

struct FirebaseStageDTO: Codable {
    @DocumentID var id: String?
    let name: String
    let symbol: String
    let colorString: String
    var iconImageURL: URL?
    var sortIndex: Int
    
    static var asStage: (Self) -> Stage = {
        Stage(
            id: .init($0.id ?? ""),
            name: $0.name,
            symbol: $0.symbol,
            colorString: $0.colorString,
            iconImageURL: $0.iconImageURL,
            sortIndex: $0.sortIndex
        )
    }
}

extension StageClient: DependencyKey {
    public static var liveValue = StageClient(
        getStages: {
            @Dependency(\.eventID) var eventID
            return FirebaseService.observeQuery(
                db.collection("events").document(eventID.rawValue).collection("stages").order(by: "sortIndex"),
                mapping: FirebaseStageDTO.asStage
            )
        }
    )
}


//
//public protocol StageServiceProtocol: Service {
//    func createStage(stage: Stage, eventID: String) async throws -> Stage
//    func updateStage(stage: Stage, eventID: String) async throws
//    func updateStageSortOrder(newOrder: IdentifiedArrayOf<Stage>, eventID: String) async throws
//    func deleteStage(stage: Stage, eventID: String) async throws
//
//    func stagesPublisher(eventID: String) ->  AnyPublisher<IdentifiedArrayOf<Stage>, FestivlError>
//    func watchStage(stage: Stage, eventID: String) throws -> AnyPublisher<Stage, FestivlError>
//}
//
//public class StageService: StageServiceProtocol {
//
//
//    private let db = Firestore.firestore()
//
//    private func getStagesRef(eventID: String) -> CollectionReference {
//        db.collection("events").document(eventID).collection("stages")
//    }
//
//    public static var shared = StageService()
//
//    public func createStage(stage: Stage, eventID: String) async throws -> Stage {
//        let document = try await createDocument(
//            reference: getStagesRef(eventID: eventID),
//            data: stage
//        )
//
//        var stage = stage
//        stage.id = document.documentID
//        return stage
//    }
//
//    public func updateStage(stage: Stage, eventID: String) async throws {
//        try await updateDocument(
//            documentReference: getStagesRef(eventID: eventID).document(stage.ensureIDExists()),
//            data: stage
//        )
//    }
//
//    public func updateStageSortOrder(newOrder: IdentifiedArrayOf<Stage>, eventID: String) async throws {
//        let batch = db.batch()
//
//        for (newIndex, stage) in newOrder.enumerated() {
//            try batch.updateData(["sortIndex": newIndex], forDocument: getStagesRef(eventID: eventID).document(stage.ensureIDExists()))
//        }
//
//        return try await withUnsafeThrowingContinuation { continuation in
//            batch.commit { error in
//                if let error = error {
//                    continuation.resume(throwing: error)
//                }
//
//                continuation.resume()
//            }
//        }
//    }
//
//    public func deleteStage(stage: Stage, eventID: String) async throws {
//        try await deleteDocument(
//            documentReference: getStagesRef(
//                eventID: eventID
//            ).document(stage.ensureIDExists())
//        )
//    }
//
//    public func stagesPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<Stage>, FestivlError> {
//        observeQuery(getStagesRef(eventID: eventID).order(by: "sortIndex"))
//    }
//
//    public func watchStage(stage: Stage, eventID: String) throws -> AnyPublisher<Stage, FestivlError> {
//        try observeDocument(getStagesRef(eventID: eventID).document(stage.ensureIDExists()))
//    }
//}
//
//struct StageMockService: StageServiceProtocol {
//    func createStage(stage: Stage, eventID: String) async throws -> Stage {
//        var stage = stage
//        stage.id = UUID().uuidString
//        return stage
//    }
//
//    func updateStage(stage: Stage, eventID: String) async throws {}
//
//    func updateStageSortOrder(newOrder: IdentifiedArrayOf<Stage>, eventID: String) async throws {}
//
//    func deleteStage(stage: Stage, eventID: String) async throws {}
//
//    func stagesPublisher(eventID: String) -> AnyPublisher<IdentifiedArrayOf<Stage>, FestivlError> {
//        Just(Stage.testValues.asIdentifedArray)
//            .setFailureType(to: FestivlError.self)
//            .eraseToAnyPublisher()
//    }
//
//    func watchStage(stage: Stage, eventID: String) throws -> AnyPublisher<Stage, FestivlError> {
//        Just(Stage.testData)
//            .setFailureType(to: FestivlError.self)
//            .eraseToAnyPublisher()
//    }
//
//    
//}
