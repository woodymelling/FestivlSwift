//
//  File.swift
//
//
//  Created by Woody on 2/9/22.
//

import Foundation
import SwiftUI

extension View {
    public func previewAllColorModes() -> some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            self.colorScheme($0)
        }
    }
}
