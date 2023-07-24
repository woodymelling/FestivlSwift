//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation

infix operator ?! : NilCoalescingPrecedence

/// Throws the right hand side error if the left hand side optional is `nil`.
public func ?!<T>(value: T?, error: @autoclosure () -> Error) throws -> T {
    guard let value = value else {
        throw error()
    }
    return value
}

public extension Optional {

    func throwingUnwrap() throws -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            throw OptionalError.unwrappedNil
        }
    }
}

public enum OptionalError: Error {
    case unwrappedNil
}
