//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/23/22.
//

import Foundation
import FirebaseFirestore
import Combine
import FestivlDependencies
import IdentifiedCollections
import Utilities

let db = Firestore.firestore()

enum FirebaseService {
    private static let db = Firestore.firestore()
    
    
    static func observeQuery<DTO: Decodable, T>(_ query: Query, mapping: @escaping (DTO) -> T) -> DataStream<IdentifiedArrayOf<T>>  where T: Identifiable {
        Publishers.QuerySnapshotPublisher(query: query)
            .flatMap { snapshot -> AnyPublisher<[DTO], FestivlError> in
                do {
                    let events = try snapshot.documents.compactMap {
                        try $0.data(as: DTO.self)
                    }

                    
                    let returnVals: [[DTO]] = [events]
                    return returnVals.publisher
                        .setFailureType(to: FestivlError.self)
                        .eraseToAnyPublisher()
                } catch {
                    let error = error
                    return Fail(error: .default(description: error.localizedDescription))
                        .eraseToAnyPublisher()
                }

            }
            .map { (values: [DTO]) in
                IdentifiedArrayOf<T>(uniqueElements: values.map { mapping($0) })
            }
            .share()
            .eraseToAnyPublisher()
    }

    static func observeDocument<DTO: Decodable, T>(_ reference: DocumentReference, mapping: @escaping (DTO) -> T) -> DataStream<T> {
        Publishers.DocumentSnapshotPublisher(documentReference: reference)
            .flatMap { snapshot -> AnyPublisher<DTO, FestivlError> in
                do {
                    let data = try snapshot.data(as: DTO.self) ?! OptionalError.unwrappedNil

                    return Just(data)
                        .setFailureType(to: FestivlError.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: .default(description: "Parsing Error"))
                        .eraseToAnyPublisher()
                }

            }
            .map { mapping($0) }
            .eraseToAnyPublisher()
    }
    
    static func observeQuery<T: Decodable & Identifiable>(_ query: Query) -> FirebaseCollectionPublisher<T> {
        Publishers.QuerySnapshotPublisher(query: query)
            .flatMap { snapshot -> AnyPublisher<[T], FestivlError> in
                do {
                    let events = try snapshot.documents.compactMap {
                        try $0.data(as: T.self)
                    }

                    return Just(events)
                        .setFailureType(to: FestivlError.self)
                        .eraseToAnyPublisher()
                } catch {
                    let error = error
                    return Fail(error: .default(description: error.localizedDescription))
                        .eraseToAnyPublisher()
                }

            }
            .map {
                IdentifiedArray(uniqueElements: $0)
            }
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    static func createDocument<T: Encodable>(
        reference: CollectionReference,
        data: T
    ) async throws -> DocumentReference {
        try reference.addDocument(from: data)
    }
}
