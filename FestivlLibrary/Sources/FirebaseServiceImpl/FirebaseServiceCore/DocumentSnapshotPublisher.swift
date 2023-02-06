//
//  DocumentSnapshotPublisher.swift
//  DocumentSnapshotPublisher
//
//  Created by Woodrow Melling on 9/3/21.
//

import Combine
import Firebase

extension Publishers {
    struct DocumentSnapshotPublisher: Publisher {
        typealias Output = DocumentSnapshot

        typealias Failure = FestivlError

        private let documentReference: DocumentReference

        init(documentReference: DocumentReference) {
            self.documentReference = documentReference
        }

        func receive<S>(subscriber: S) where S : Subscriber, FestivlError == S.Failure, DocumentSnapshot == S.Input {
            let documentSnapshotSubscription = DocumentSnapshotSubscription(subscriber: subscriber, reference: self.documentReference)
            subscriber.receive(subscription: documentSnapshotSubscription)
        }


        class DocumentSnapshotSubscription<S: Subscriber>: Subscription where S.Input == DocumentSnapshot, S.Failure == FestivlError {

            private var subscriber: S?
            private var listener: ListenerRegistration?

            init(subscriber: S, reference: DocumentReference) {
                listener = reference.addSnapshotListener { documentSnapshot, error in
                    if let error = error {
                        subscriber.receive(completion: .failure(.default(description: error.localizedDescription)))
                    } else if let documentSnapshot = documentSnapshot {
                        _ = subscriber.receive(documentSnapshot)
                    } else {
                        subscriber.receive(completion: .finished)
                    }
                }
            }

            func request(_ demand: Subscribers.Demand) {}

            func cancel() {
                subscriber = nil
                listener = nil
            }
        }
    }
}
