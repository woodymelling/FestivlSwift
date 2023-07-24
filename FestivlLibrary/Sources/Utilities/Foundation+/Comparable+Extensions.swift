//
//  File.swift
//  
//
//  Created by Woody on 3/14/22.
//

import Foundation

public extension Comparable {
    @inlinable
    func floor(at floor: Self) -> Self {
        self < floor ? floor : self
    }

    @inlinable
    func ceiling(at ceiling: Self) -> Self {
        self > ceiling ? ceiling : self
    }

    @inlinable
    func bounded(min: Self, max: Self) -> Self {
        self.floor(at: min).ceiling(at: max)
    }
}
