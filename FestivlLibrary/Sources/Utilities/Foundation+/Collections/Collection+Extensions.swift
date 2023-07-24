//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/30/22.
//

import Foundation

public extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        if let self, !self.isEmpty {
            return false
        } else {
            return true
        }
    }
}

extension Collection {
    public func sorted<T, U>(by keyPath: KeyPath<Element, T>, and secondaryKeyPath: KeyPath<Element, U>) -> [Element] where T : Comparable, U: Comparable {
        self.sorted {
            if $0[keyPath: keyPath] == $1[keyPath: keyPath] {
                return $0[keyPath: secondaryKeyPath] < $1[keyPath: secondaryKeyPath]
            } else {
                return $0[keyPath: keyPath] < $1[keyPath: keyPath]
            }
        }
    }
}
