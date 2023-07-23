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
    public init(getStages: @escaping () -> DataStream<IdentifiedArrayOf<Stage>>) {
        self.getStages = getStages
    }
    
    public var getStages: () -> DataStream<IdentifiedArrayOf<Stage>>
}

public enum StageClientKey: TestDependencyKey {
    public static var testValue = StageClient(
        getStages: XCTUnimplemented("StageClient.getStages")
    )
    
    public static var previewValue = StageClient(
        getStages: { Just(Stage.previewData.asIdentifiedArray).eraseToDataStream() }
    )
}

public extension DependencyValues {
    var stageClient: StageClient {
        get { self[StageClientKey.self] }
        set { self[StageClientKey.self] = newValue }
    }
}


