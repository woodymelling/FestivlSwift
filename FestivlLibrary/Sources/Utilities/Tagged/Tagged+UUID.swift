//
//  Tagged+UUID.swift
//  
//
//  Created by Woodrow Melling on 8/13/23.
//

import Foundation
import Tagged

public extension Tagged where RawValue == UUID {
    init(_ intValue: Int) {
        self.init(UUID(intValue))
    }
}

extension Tagged where RawValue == String {
    public init(_ int: Int) {
        self.init(rawValue: "\(int)")
    }
}
