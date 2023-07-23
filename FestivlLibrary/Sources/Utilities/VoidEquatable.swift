//
//  File.swift
//  
//
//  Created by Woodrow Melling on 2/14/23.
//

import Foundation

public struct Blank: Sendable, Equatable {
    public init(_ any: Any) {}
    
    public static func ==(_: Self, _: Self) -> Bool {
        true
    }
}
