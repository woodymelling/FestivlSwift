//
//  File.swift
//  
//
//  Created by Woody on 2/18/22.
//

import Foundation
import IdentifiedCollections

public extension Collection where Element: Identifiable {
    var asIdentifedArray: IdentifiedArrayOf<Element> {
        IdentifiedArray(uniqueElements: self)
    }
}

