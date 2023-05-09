//
//  Event.swift
//
//
//  Created by Woody on 2/13/2022.
//

import ComposableArchitecture
import Models
import Combine
import Utilities
import SwiftUI
import Kingfisher

import ScheduleFeature
import ArtistListFeature
import ExploreFeature
import MoreFeature

import ShowScheduleItemDependency

import ComposableUserNotifications
import FestivlDependencies
import Components

public struct EventFeature: ReducerProtocol {
    public init() {}

    @Dependency(\.userDefaults.eventID) var eventID
    @Dependency(\.internalPreviewClient) var internalPreviewClient
    
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.userNotifications) var userNotifications
    
    @Dependency(\.showScheduleItem) var showScheduleItem
    
    
    public struct State: Equatable {
        var selectedTab: Tab = .schedule
        
        var scheduleState: ScheduleLoadingFeature.State = .init()
        var artistListState: ArtistListFeature.State = .init()
        var exploreState: ExploreFeature.State = .init()
        var moreState: MoreFeature.State = .init()
        
        var eventData: EventData?
        
        
        
        public init() {}
    }
    
    public enum Action {
        case task
        
        case didSelectTab(Tab)
        
        case setUpWhenDataLoaded(EventData)
        
        case showScheduleItem(ScheduleItem)
        
        case artistListAction(ArtistListFeature.Action)
        case scheduleAction(ScheduleLoadingFeature.Action)
        case exploreAction(ExploreFeature.Action)
        case moreAction(MoreFeature.Action)
        
        case userNotification(UserNotificationClient.DelegateAction)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .task:
                return .merge(
                    .run { send in
                        for try await data in eventDataClient.getData(self.eventID).values {
                            await send(.setUpWhenDataLoaded(data))
                        }
                    },
                    
                    .run { send in
                        for await event in userNotifications.delegate() {
                            await send(.userNotification(event))
                        }
                    },

                    .run { send in
                        for await scheduleItemToShow in showScheduleItem.items().values {
                            await send(.showScheduleItem(scheduleItemToShow))
                        }
                    }
                )
                
            case .didSelectTab(let tab):
                state.selectedTab = tab
                return .none
                
            case .showScheduleItem(let scheduleItem):
                state.selectedTab = .schedule
                
                return .task { .scheduleAction(.scheduleAction(.showAndHighlightCard(scheduleItem))) }

            case .setUpWhenDataLoaded(let data):
                state.eventData = data
                
                let hasScheduleAccess = data.event.scheduleIsPublished || self.internalPreviewClient.internalPreviewsAreUnlocked(self.eventID)
                
                
                if !hasScheduleAccess && state.selectedTab == .schedule {
                    state.selectedTab = .artists
                }
                
                NSTimeZone.default = data.event.timeZone
                
                return .fireAndForget {
                    async let _ = await ImageCacher.preFetchImage(urls: data.artists.compactMap { $0.imageURL })
                    async let _ = await ImageCacher.preFetchImage(urls: data.stages.compactMap { $0.iconImageURL })
                }
                
            case let .userNotification(.willPresentNotification(_, completion)):
                completion([.list, .banner, .sound])
                
                return .none
                
            case let .userNotification(.didReceiveResponse(response, completion)):
                return navigateToSetFromNotification(
                    state: &state,
                    response: response,
                    completion: completion
                )
                
            case .userNotification(.openSettingsForNotification):
                return .none
                
            case .scheduleAction, .artistListAction, .exploreAction,  .moreAction:
                return .none

            }
        }
        
        Scope(state: \.artistListState, action: /Action.artistListAction) {
            ArtistListFeature()
        }
        
        Scope(state: \.scheduleState, action: /Action.scheduleAction) {
            ScheduleLoadingFeature()
        }
        
        Scope(state: \.exploreState, action: /Action.exploreAction) {
            ExploreFeature()
        }
        
        Scope(state: \.moreState, action: /Action.moreAction) {
            MoreFeature()
        }
    }
    
    
    func navigateToSetFromNotification(
        state: inout State,
        response: ComposableUserNotifications.Notification.Response,
        completion: @escaping () -> Void
    ) -> EffectTask<Action> {
        guard let schedule = state.eventData?.schedule else { return .none }
        if case .user(let action) = response {
            print("ACTIONIDENTIFIER", response.actionIdentifier)
            switch response.actionIdentifier {
            case "GO_TO_SET_ACTION", UNNotificationDefaultActionIdentifier:
                if let setID = action.notification.request.content.userInfo()["SET_ID"] as? String,
                   let scheduleItem = schedule[id: .init(setID)] {
                    state.selectedTab = .schedule
                    return .concatenate(
                        .send( .scheduleAction(.scheduleAction(.showAndHighlightCard(scheduleItem)))),
                        .run  { _ in
                            completion()
                        }
                    )
                }
            default:
                break
            }
        }
        return .none
    }
}
