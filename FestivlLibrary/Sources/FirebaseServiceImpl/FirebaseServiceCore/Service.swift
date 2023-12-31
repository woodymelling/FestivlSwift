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
import Utilities
import IdentifiedCollections
import FestivlDependencies

public protocol Service {
    
}


extension Service {
    var storedEventID: String {
        UserDefaults.standard.string(forKey: "storedEventID") ?? ""
    }
}

public extension Service {
 
//    
//    @discardableResult func createDocument<T: Encodable & SettableIdentifiable, Wrapped>(reference: CollectionReference, data: T, batch: WriteBatch? = nil) async throws -> DocumentReference where T.ID == Wrapped? {
//        var mutableData = data
//        mutableData.id = nil
//
//        return try await withUnsafeThrowingContinuation { continuation in
//            do {
//                let document: DocumentReference
//                if let batch = batch {
//
//                    let documentReference = reference.document(UUID().uuidString)
//                    try batch.setData(from: mutableData, forDocument: documentReference)
//                    document = documentReference
//                } else {
//
//                    document = try reference.addDocument(from: mutableData)
//                }
//                continuation.resume(returning: document)
//            } catch {
//                continuation.resume(throwing: error)
//            }
//
//        }
//    }
//
//    func updateDocument<T: Encodable>(documentReference: DocumentReference, data: T, batch: WriteBatch? = nil) async throws {
//        return try await withUnsafeThrowingContinuation { continuation in
//            do {
//                if let batch = batch {
//                    try batch.setData(from: data, forDocument: documentReference)
//                } else {
//                    try documentReference.setData(from: data)
//                }
//
//                continuation.resume()
//            } catch {
//                continuation.resume(throwing: error)
//            }
//        }
//    }

    func deleteDocument(documentReference: DocumentReference, batch: WriteBatch? = nil) async throws {
        return try await withUnsafeThrowingContinuation { continuation in

            if let batch = batch {
                batch.deleteDocument(documentReference)
            } else {

                documentReference.delete()
            }
            continuation.resume()
        }
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


public typealias FirebaseCollectionPublisher<T: Decodable & Identifiable> = AnyPublisher<IdentifiedArrayOf<T>, FestivlError>
