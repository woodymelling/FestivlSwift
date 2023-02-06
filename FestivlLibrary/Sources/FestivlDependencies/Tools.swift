//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/6/22.
//

import Foundation

public typealias DataStream<T> = AsyncThrowingStream<T, any Error>

extension DataStream {
    static func yield(_ value: Element) -> DataStream<Element> {
        AsyncThrowingStream<Element, any Error> { continuation in
            continuation.yield(value)
        }
    }
}
