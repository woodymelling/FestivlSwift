//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/7/22.
//

import Foundation
import Dependencies

public enum FestivlEnvironment {
    case live
    case test
}

private enum EnvionmentKey: DependencyKey {
    public static let liveValue = FestivlEnvironment.live
    public static let previewValue = FestivlEnvironment.test
}

public extension DependencyValues {
    var currentEnvironment: FestivlEnvironment {
        get { self[EnvionmentKey.self] }
        set { self[EnvionmentKey.self] = newValue }
    }
}

