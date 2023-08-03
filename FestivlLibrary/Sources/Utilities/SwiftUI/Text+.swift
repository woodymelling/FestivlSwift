//
//  Text+.swift
//  
//
//  Created by Woodrow Melling on 8/1/23.
//

import Foundation
import SwiftUI

public extension Text {
    init(localized: String) {
        self.init(LocalizedStringKey(localized))
    }
    
    init(hiddenWhenNil text: String?) {
        self.init(text ?? " ")
    }
}
