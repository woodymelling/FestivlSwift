//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/16/22.
//

import Foundation
import ComposableArchitecture

public extension Effect where Failure == Never {
    static func asyncTask(
        _ action: @escaping () async throws -> Output
    ) -> Effect<Result<Output, NSError>, Never> {
        Effect<Output, NSError>.future { promise in
            Task {
                promise(.success(try await action()))
            }
        }
        .catchToEffect()
        .eraseToEffect()
    }
}
