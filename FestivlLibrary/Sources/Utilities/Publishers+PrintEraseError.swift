//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import Foundation
import Combine

public extension Publisher {
    func eraseErrorToPrint(errorSource: String) -> AnyPublisher<Output, Never> {
        return self.catch { error -> Empty<Output, Never> in
            Swift.print("\(errorSource) error:", error)
            return Empty<Output, Never>()
            // TODO: Error Handling
        }
        .eraseToAnyPublisher()
    }
}
