//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/7/22.
//

import Foundation
import Models
import IdentifiedCollections
import XCTestDynamicOverlay
import Dependencies
import DependenciesMacros
import Combine

@DependencyClient
public struct StageClient {
    public var getStages: () -> DataStream<IdentifiedArrayOf<Stage>> = { Empty().eraseToDataStream() }
}

extension StageClient: TestDependencyKey {
    public static var testValue = Self()

    public static var previewValue = StageClient(
        getStages: { Just(Stage.previewData.asIdentifiedArray).eraseToDataStream() }
    )
}

public extension DependencyValues {
    var stageClient: StageClient {
        get { self[StageClient.self] }
        set { self[StageClient.self] = newValue }
    }
}


