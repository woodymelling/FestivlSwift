//
//  LoadableStatusIndicator.swift
//  
//
//  Created by Woodrow Melling on 8/19/23.
//

import Foundation
import SwiftUI
import Utilities

public struct LoadableStatusIndicator: View {
    public init(_ state: Loader<Bool>? = nil) {
        self.state = state
    }

    var state: Loader<Bool>?

    public var body: some View {
        Group {
            switch state {
            case .none: Image(systemName: "circle")
            case .loading: ProgressView()
            case .loaded(true): Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.systemGreen)
            case .loaded(false): Image(systemName: "x.circle.fill").foregroundStyle(Color.systemRed)
            }
        }
        .frame(square: 10)
    }
}

#Preview {
    VStack(spacing: 0) {
        LoadableStatusIndicator(nil)
        LoadableStatusIndicator(.loading)
        LoadableStatusIndicator(.loaded(true))
        LoadableStatusIndicator(.loaded(false))
    }
}
