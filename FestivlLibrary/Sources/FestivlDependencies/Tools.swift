//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/6/22.
//

import Foundation
import Combine
import ComposableArchitecture


public enum FestivlError: Error {
    case `default`(description: String)
}

public typealias DataStream<T> = AnyPublisher<T, FestivlError>

public extension Effect {
    static func observe<T>(_ dataStream: DataStream<T>, sending action: @escaping (T) -> Action) -> Effect<Action> {
        Effect.publisher {
            dataStream
                .eraseErrorToPrint(errorSource: String(describing: T.self))
                .map(action)
        }
    }
    
    static func observe<T>(_ dataStream: AnyPublisher<T, Never>, sending action: @escaping (T) -> Action) -> Effect<Action> {
        Effect.publisher {
            dataStream.map(action)
        }
    }
}

extension Publisher where Failure == Never {
    public func eraseToDataStream() -> DataStream<Output> {
        self.setFailureType(to: FestivlError.self).share().eraseToAnyPublisher()
    }
}

extension DataStream {
    static func just(_ value: Output) -> DataStream<Output> {
        return Just(value).eraseToDataStream()
    }
    
    static func just(_ value: Output?) -> DataStream<Output> {
        if let value {
            return Just(value).eraseToDataStream()
        } else {
            return Fail<Output, FestivlError>(error: .default(description: "not found")).eraseToAnyPublisher()
        }
    }
}
