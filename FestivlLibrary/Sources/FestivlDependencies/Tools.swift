//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/6/22.
//

import Foundation
import Combine


public enum FestivlError: Error {
    case `default`(description: String)
}

public typealias DataStream<T> = AnyPublisher<T, FestivlError>

extension Publisher where Failure == Never {
    func eraseToDataStream() -> DataStream<Output> {
        self.setFailureType(to: FestivlError.self).eraseToAnyPublisher()
    }
}
