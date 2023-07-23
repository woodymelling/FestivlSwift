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

public struct MoreFeature: Reducer {
    public init() {}
    
    @Dependency(\.isEventSpecificApplication) var isEventSpecificApplication
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.internalPreviewClient) var internalPreviewClient
    
    public struct State: Equatable {
        public init() {}
        
        var eventData: EventData?
        var isEventSpecificApplication: Bool = true
        
        var isShowingKeyInput: Bool = false
        @BindingState var keyInputText: String = ""
        
        @PresentationState var destination: Destination.State?
    }
    
    public enum Action: BindableAction {
        case task
        case binding(BindingAction<State>)
        
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
    

    public struct Destination: Reducer {
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

        public var body: some ReducerOf<Self> {
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
    
    public var body: some Reducer<MoreFeature.State, MoreFeature.Action> {
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .task:
                state.isEventSpecificApplication = isEventSpecificApplication
                
                return .observe(eventDataClient.getData(), sending: Action.dataLoaded)
                
            case .didExitEvent:
                return .none
                
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
