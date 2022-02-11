//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation
import Combine
import Firebase

extension Publishers {
    struct QuerySnapshotPublisher: Publisher {
        typealias Output = QuerySnapshot

        typealias Failure = FestivlError

        private let query: Query

        init(query: Query) {
            self.query = query
        }

        func receive<S>(subscriber: S) where S : Subscriber, FestivlError == S.Failure, QuerySnapshot == S.Input {
            let querySnapshotSubscription = QuerySnapshotSubscription(subscriber: subscriber, query: self.query)
            subscriber.receive(subscription: querySnapshotSubscription)
        }


        class QuerySnapshotSubscription<S: Subscriber>: Subscription where S.Input == QuerySnapshot, S.Failure == FestivlError {

            private var subscriber: S?
            private var listener: ListenerRegistration?

            init(subscriber: S, query: Query) {
                listener = query.addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        subscriber.receive(completion: .failure(.default(description: error.localizedDescription)))
                    } else if let querySnapshot = querySnapshot {
                        _ = subscriber.receive(querySnapshot)
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
