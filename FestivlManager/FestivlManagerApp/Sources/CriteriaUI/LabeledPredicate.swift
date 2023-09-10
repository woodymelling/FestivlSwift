//
//  LabeledPredicate.swift
//  
//
//  Created by Woodrow Melling on 8/19/23.
//

import Foundation
import SwiftUI

public struct LabeledPredicate<each Input> {
    public var label: LocalizedStringKey
    public var predicate: Predicate<repeat each Input>

    public init(_ label: LocalizedStringKey, for predicate: Predicate<repeat each Input>) {
        self.label = label
        self.predicate = predicate
    }

    public func evaluate(_ input: repeat each Input) throws -> Bool {
        try predicate.evaluate(repeat each input)
    }
}

public extension Predicate {
    @inlinable func labeled(_ label: LocalizedStringKey) -> LabeledPredicate<repeat each Input> {
        return LabeledPredicate(label, for: self)
    }
}
