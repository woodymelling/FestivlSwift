//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/18/22.
//

import Foundation

public extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}
