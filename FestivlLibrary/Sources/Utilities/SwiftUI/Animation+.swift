//
//  Animation+.swift
//  
//
//  Created by Woodrow Melling on 8/19/23.
//

import Foundation
import SwiftUI

public extension View {
    @inlinable func animation<V>(
        _ animation: Animation?,
        value: V,
        when: Bool
    ) -> some View where V : Equatable {
        self.animation(
            when ? animation : .linear(duration: 0),
            value: value
        )
    }
}
