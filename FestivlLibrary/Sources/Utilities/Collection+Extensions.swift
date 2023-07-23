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
