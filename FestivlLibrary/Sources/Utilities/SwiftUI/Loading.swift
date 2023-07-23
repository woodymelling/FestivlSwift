//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/28/22.
//

import Foundation
import SwiftUI

public extension View {
    func loading(_ isLoading: Bool) -> some View {
        if isLoading {
            return AnyView(
                ZStack {
                    ProgressView()
                    self
                }
            )
        } else {
            return AnyView(self)
        }
    }
}

