//
// MoreDomain.swift
//
//
//  Created by Woody on 4/22/2022.
//

import ComposableArchitecture
import Models
import FestivlDependencies
import NotificationsFeature

public struct MoreFeature: ReducerProtocol {
    public init() {}
    
    
    @Dependency(\.eventID) var eventID
    @Dependency(\.isEventSpecificApplication) var isEventSpecificApplication
    @Dependency(\.eventDataClient) var eventDataClient
    
    public struct State: Equatable {
        public init() {}
        
        var eventData: EventData?
        var isEventSpecificApplication: Bool = true
        
        var notificationsState: NotificationsFeature.State = .init()
    }
    
    public enum Action {
        case didExitEvent
        case task
        
        case dataLoaded(EventData)
        
        case notificationsAction(NotificationsFeature.Action)
    }
    
    public var body: some ReducerProtocol<MoreFeature.State, MoreFeature.Action> {
        Reduce { state, action in
            switch action {
            case .didExitEvent:
                return .none
            case .task:
                state.isEventSpecificApplication = isEventSpecificApplication
                
                return .run { send in
                    for try await data in eventDataClient.getData(eventID.value).values {
                        await send(.dataLoaded(data))
                    }
                } catch: { _, _ in
                    print("Event Data Loading Error")
                }
                
            case .dataLoaded(let data):
                state.eventData = data
                
                return .none
                
            case .notificationsAction:
                return .none
            }
        }
        
        Scope(state: \.notificationsState, action: /Action.notificationsAction) {
            NotificationsFeature()
        }
    }
}
