//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/28/23.
//


import Foundation
import Combine
import Models
import Dependencies
import DependenciesMacros
import Utilities
import IdentifiedCollections


@DependencyClient
public struct WorkshopsClient {
    public var fetchWorkshops: () -> DataStream<IdentifiedArrayOf<Workshop>> = { Empty().eraseToDataStream() }
    public var createWorkshop: (Workshop) async throws -> Void
}


extension WorkshopsClient: TestDependencyKey {
    public static var testValue: WorkshopsClient = Self()

    public static var previewValue = WorkshopsClient(
        fetchWorkshops: {
            Just(Workshop.testData.values.flatMap { $0 }.asIdentifiedArray)
                .eraseToDataStream()
        },
        createWorkshop: { _ in }
    )
}

extension DependencyValues {
    public var workshopsClient: WorkshopsClient {
        get { self[WorkshopsClient.self] }
        set { self[WorkshopsClient.self] = newValue }
    }
}
