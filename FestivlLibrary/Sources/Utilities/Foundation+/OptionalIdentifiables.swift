//
//  Identifiable+Optional.swift
//  Identifiable+Optional
//
//  Created by Woodrow Melling on 9/3/21.
//

import Foundation

public extension Identifiable where ID: IsOptional {
    func ensureIDExists() throws -> ID.Wrapped {
        if let id = self.id.optionalValue {
            return id
        } else {
            throw OptionalIdentifiableError.noID
        }
    }
}

public enum OptionalIdentifiableError: Error {
    case noID
}

public protocol IsOptional {
    associatedtype Wrapped

    var optionalValue: Wrapped? { get }
}

extension Optional: IsOptional {
    public var optionalValue: Wrapped? {
        return self
    }
}
