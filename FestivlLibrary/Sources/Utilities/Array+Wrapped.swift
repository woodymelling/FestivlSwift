//
//  File.swift
//  
//
//  Created by Woody on 3/2/22.
//

import Foundation


public extension Array {
    subscript(wrapped index: Int) -> Element {
        get {
            self[index % count]
        }
        set {
            self[index % count] = newValue
        }
    }
}
