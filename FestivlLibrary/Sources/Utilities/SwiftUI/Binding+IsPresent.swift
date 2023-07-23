//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/20/22.
//

import Foundation
import SwiftUI

extension Binding {
    public func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        .init(
            get: {
                self.wrappedValue != nil
                
            },
            set: { isPresent, transaction in
                if !isPresent {
                    self.transaction(transaction).wrappedValue = nil
                }
            }
        )
    }
}
