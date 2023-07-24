//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/22/23.
//

import Foundation

public extension Sequence {
    func sorted<T: Comparable>(by keyPath:KeyPath<Element, T>) -> [Element]{
        return sorted {a, b in
            return a[keyPath: keyPath] < b[keyPath:keyPath]
        }
    }
    
    func map <T> (_ keyPath: KeyPath<Element, T>) -> [T] {
        return map {$0[keyPath: keyPath]}
    }
    
    func min <T: Comparable> (_ keyPath: KeyPath<Element, T>) -> T? {
        return map(keyPath).min()
    }
    
    func max<T: Comparable> (_ keyPath: KeyPath<Element, T>) -> T? {
        return map(keyPath).max()
    }
    
}
