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
import WorkshopsFeature
import XCTestDynamicOverlay

public struct MoreFeature: ReducerProtocol {
    public init() {}
    
    @Dependency(\.userDefaults.eventID) var eventID
    @Dependency(\.isEventSpecificApplication) var isEventSpecificApplication
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.internalPreviewClient) var internalPreviewClient
    
    public struct State: Equatable {
        public init() {}
        
        var eventData: EventData?
        var isEventSpecificApplication: Bool = true
        
        var isShowingKeyInput: Bool = false
        var keyInputText: String = ""
        
        @PresentationState var destination: Destination.State?
    }
    
    public enum Action {
        case task
        case dataLoaded(EventData)
        
        case didTapNotifications
        case didTapSiteMap
        case didTapContactInfo
        case didTapAddress
        case didTapWorkshops
        
        case didExitEvent
        
        case didTap7Times
        case didUpdateKeyInput(String)
        case didTapUnlockInternalPreview
        
        case destination(PresentationAction<Destination.Action>)
    }
    

    public struct Destination: ReducerProtocol {
        public enum State: Equatable {
            case address(AddressFeature.State)
            case contactInfo(ContactInfoFeature.State)
            case siteMap(SiteMapFeature.State)
            case notifications(NotificationsFeature.State)
            case workshops(WorkshopsFeature.State)
        }

        public enum Action {
            case address(AddressFeature.Action)
            case notifications(NotificationsFeature.Action)
            case siteMap(SiteMapFeature.Action)
            case contactInfo(ContactInfoFeature.Action)
            case workshops(WorkshopsFeature.Action)
        }

        public var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.siteMap, action: /Action.siteMap) {
                SiteMapFeature()
            }
            
            Scope(state: /State.notifications, action: /Action.notifications) {
                NotificationsFeature()
            }
            
            Scope(state: /State.address, action: /Action.address) {
                AddressFeature()
            }

            Scope(state: /State.contactInfo, action: /Action.contactInfo) {
                ContactInfoFeature()
            }
            
            Scope(state: /State.workshops, action: /Action.workshops) {
                WorkshopsFeature()
            }
        }
    }
    
    public var body: some ReducerProtocol<MoreFeature.State, MoreFeature.Action> {
        Reduce { state, action in
            switch action {
            case .didExitEvent:
                return .none
            case .task:
                state.isEventSpecificApplication = isEventSpecificApplication
                
                return .run { send in
                    for try await data in eventDataClient.getData(self.eventID).values {
                        await send(.dataLoaded(data))
                    }
                } catch: { _, _ in
                    print("Event Data Loading Error")
                }
                
            case .didTapNotifications:
                state.destination = .notifications(NotificationsFeature.State())
                
            case .didTapSiteMap:
                
                guard let siteMapImageURL = state.eventData?.event.siteMapImageURL else {
                    XCTFail("Cannot navigate to the site map without an siteMapImageURL")
                    return .none
                }
                state.destination = .siteMap(SiteMapFeature.State(url: siteMapImageURL))
                
            case .didTapContactInfo:
                guard let contactInfo = state.eventData?.event.contactNumbers else {
                    XCTFail("Cannot navigate to the contact numbers without contact numbers")
                    return .none
                }
                state.destination = .contactInfo(ContactInfoFeature.State(contactNumbers: contactInfo))
                
            case .didTapAddress:
                guard let event = state.eventData?.event, let address = event.address else {
                    XCTFail("Cannot navigate to the address page without an address")
                    return .none
                }
                
                state.destination = .address(AddressFeature.State(address: address, latitude: event.latitude ?? "", longitude: event.longitude ?? ""))
                
            case .didTapWorkshops:
                state.destination = .workshops(.init())
                
            case .dataLoaded(let data):
                state.eventData = data
                
                return .none
                
            case .destination:
                return .none
                
            case .didTap7Times:
                state.isShowingKeyInput = true
                
            case .didUpdateKeyInput(let key):
                state.keyInputText = key
                return .none
                
            case .didTapUnlockInternalPreview:
                guard let event = state.eventData?.event, let internalPreviewKey = event.internalPreviewKey else { return .none }
                if internalPreviewKey == state.keyInputText {
                    internalPreviewClient.unlockInternalPreviews(event.id)
                }
            }
            return .none
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}
