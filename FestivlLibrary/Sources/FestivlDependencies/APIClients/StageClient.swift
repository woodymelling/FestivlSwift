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
import Combine

public struct StageClient {
    public var getStages: (Event.ID) -> DataStream<IdentifiedArrayOf<Stage>>
}

public enum StageClientKey: TestDependencyKey {
    public static var testValue = StageClient(
        getStages: XCTUnimplemented("StageClient.getStages")
    )
    
    public static var previewValue = StageClient(
        getStages: { _ in Just(Stage.testValues.asIdentifedArray).eraseToAnyPublisher() }
    )
}

public extension DependencyValues {
    var stageClient: StageClient {
        get { self[StageClientKey.self] }
        set { self[StageClientKey.self] = newValue }
    }
}


