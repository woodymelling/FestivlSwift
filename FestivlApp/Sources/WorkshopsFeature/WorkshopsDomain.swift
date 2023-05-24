//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/22/23.
//

import Foundation
import ComposableArchitecture
import Utilities
import Models
import FestivlDependencies

struct WorkshopsDomain: Reducer {
    @Dependency(\.workshopsClient) var workshopsClient
    @Dependency(\.userDefaults.eventID) var eventID
    
    struct State: Equatable {
        var selectedDate: CalendarDate
        
        var workshops: [CalendarDate : IdentifiedArrayOf<Workshop>]
    }
    
    enum Action: Equatable {
        case task
        
        case loadedWorkshops([CalendarDate : IdentifiedArrayOf<Workshop>])
    }
    
    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .task:
                return .run { send in
                    for try await workshops in workshopsClient.fetchWorkshops(eventID).values {
                        await send(.loadedWorkshops(workshops))
                    }
                }
                
            case let .loadedWorkshops(workshops):
                state.workshops = workshops
                
                return .none
            }
        }
    }
}

import Combine

struct WorkshopsClient {
    var fetchWorkshops: (Event.ID) -> DataStream<[CalendarDate : IdentifiedArrayOf<Workshop>]>
}


struct WorkshopsClientDependencyKey: TestDependencyKey {
    static var testValue = WorkshopsClient(
        fetchWorkshops: unimplemented("WorkshopsClient.fetchWorkshops")
    )
    
    static var previewValue = WorkshopsClient(
        fetchWorkshops: { _ in
            Just(Workshop.testData)
                .eraseToDataStream()
        }
    )
}

extension DependencyValues {
    var workshopsClient: WorkshopsClient {
        get { self[WorkshopsClientDependencyKey.self] }
        set { self[WorkshopsClientDependencyKey.self] = newValue }
    }
}
