//
//  File.swift
//  
//
//  Created by Woody on 2/18/22.
//

import Foundation
import IdentifiedCollections

public extension Collection where Element: Identifiable {
    var asIdentifiedArray: IdentifiedArrayOf<Element> {
        IdentifiedArray(uniqueElements: self)
    }
    
    func asIdentifiedArray(unchecked: Bool = false) -> IdentifiedArrayOf<Element> {
        if unchecked {
            IdentifiedArray(uncheckedUniqueElements: self)
        } else {
            self.asIdentifiedArray
        }
    }
}

