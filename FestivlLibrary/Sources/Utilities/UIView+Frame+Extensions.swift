//
//  File.swift
//  
//
//  Created by Woody on 2/16/22.
//

import Foundation
import SwiftUI

public extension View {
    func frame(square side: CGFloat) -> some View {
        self.frame(width: side, height: side)
    }
}
