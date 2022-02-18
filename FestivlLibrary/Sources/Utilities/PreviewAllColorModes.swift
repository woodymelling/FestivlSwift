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
        Group {
            self.colorScheme(.dark).background(.black)
            self.colorScheme(.light)
        }
    }
}
