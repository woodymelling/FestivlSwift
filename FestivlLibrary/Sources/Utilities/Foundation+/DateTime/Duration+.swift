//
//  Duration+.swift
//  
//
//  Created by Woodrow Melling on 8/19/23.
//

import Foundation

public extension Duration {
    var seconds: Double {
        return Double(components.seconds) + Double(components.attoseconds) * 1e-18
    }
}
