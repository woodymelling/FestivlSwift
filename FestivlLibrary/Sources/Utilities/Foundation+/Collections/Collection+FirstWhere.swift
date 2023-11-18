//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/17/23.
//

import Foundation

extension Collection {
    public func first<ElementOfResult>(
        _ transform: (Self.Element) throws -> ElementOfResult?
    ) rethrows -> ElementOfResult? {
        try self.compactMap(transform).first
    }
}
