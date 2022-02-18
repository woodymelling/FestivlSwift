//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation

import Foundation
import Combine
import Firebase
import FirebaseFirestoreSwift
import Utilities
import IdentifiedCollections

public protocol Service { }

public extension Service {
    @discardableResult func createDocument<T: Encodable>(reference: CollectionReference, data: T) async throws -> DocumentReference {
        return try await withUnsafeThrowingContinuation { continuation in
            do {
                let document = try reference.addDocument(from: data)
                continuation.resume(returning: document)
            } catch {
                continuation.resume(throwing: error)
            }

        }
    }

    func updateDocument<T: Encodable>(documentReference: DocumentReference, data: T) async throws {
        return try await withUnsafeThrowingContinuation { continuation in
            do {
                try documentReference.setData(from: data)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func observeQuery<T: Decodable>(_ query: Query) -> AnyPublisher<IdentifiedArrayOf<T>, FestivlError>  where T: Identifiable {
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

    func observeDocument<T: Decodable>(_ reference: DocumentReference) -> AnyPublisher<T, FestivlError> {
        Publishers.DocumentSnapshotPublisher(documentReference: reference)
            .flatMap { snapshot -> AnyPublisher<T, FestivlError> in
                do {
                    let data = try snapshot.data(as: T.self) ?! OptionalError.unwrappedNil

                    return Just(data)
                        .setFailureType(to: FestivlError.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: .default(description: "Parsing Error"))
                        .eraseToAnyPublisher()
                }

            }
            .eraseToAnyPublisher()
    }
}

public enum FestivlError: Error {
    case `default`(description: String? = nil)

    var errorDescription: String? {
        switch self {
        case let .default(description):
            return description ?? "Something went wrong"
        }
    }
}
