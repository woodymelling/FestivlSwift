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
import Utilities
import IdentifiedCollections


public struct WorkshopsClient {
    public init(
        fetchWorkshops: @escaping (Event.ID) -> DataStream<IdentifiedArrayOf<Workshop>>,
        createWorkshop: @escaping (Event.ID, Workshop) async throws -> Void
    ) {
        self.fetchWorkshops = fetchWorkshops
        self.createWorkshop = createWorkshop
    }
    
    public var fetchWorkshops: (Event.ID) -> DataStream<IdentifiedArrayOf<Workshop>>
    public var createWorkshop: (Event.ID, Workshop) async throws -> Void
}


public struct WorkshopsClientDependencyKey: TestDependencyKey {
    public static var testValue = WorkshopsClient(
        fetchWorkshops: unimplemented("WorkshopsClient.fetchWorkshops"),
        createWorkshop: unimplemented("WorkshopsClient.createWorkshop")
    )
    
    public static var previewValue = WorkshopsClient(
        fetchWorkshops: { _ in
            Just(Workshop.testData.values.flatMap { $0 }.asIdentifiedArray)
                .eraseToDataStream()
        },
        createWorkshop: { _, _ in }
    )
}

extension DependencyValues {
    public var workshopsClient: WorkshopsClient {
        get { self[WorkshopsClientDependencyKey.self] }
        set { self[WorkshopsClientDependencyKey.self] = newValue }
    }
}
