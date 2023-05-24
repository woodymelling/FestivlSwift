//
// GroupSetDetailDomain.swift
//
//
//  Created by Woody on 4/16/2022.
//

import ComposableArchitecture
import Models
import ArtistPageFeature
import ShowScheduleItemDependency
import FestivlDependencies
import Combine
import Tagged


public struct GroupSetDetail: ReducerProtocol {
    
    public init() {}
    
    @Dependency(\.userDefaults.eventID) var eventID
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.userFavoritesClient) var userFavoritesClient
    
    @Dependency(\.showScheduleItem) var showScheduleItem
    
    public struct State: Equatable {
        public init(groupSet: ScheduleItem) {
            self.groupSet = groupSet
        }

        public var groupSet: ScheduleItem
        public var event: Event?
        public var schedule: Schedule?
        public var stages: IdentifiedArrayOf<Stage> = .init()

        public var artists: IdentifiedArrayOf<Artist> = .init()
        
        public var userFavorites: UserFavorites = .init()
        
        var showArtistImages: Bool = false
        
        @PresentationState var destination: Destination.State?
    }
    
    public enum Action {
        case task
        case dataUpdate(EventData, UserFavorites)
        
        case didTapScheduleItem(ScheduleItem)
        case didTapArtist(Artist.ID)

        case destination(PresentationAction<Destination.Action>)
    }
    
    public struct Destination: Reducer {
        public enum State: Equatable {
            case artistDetail(ArtistDetail.State)
        }
        
        public enum Action {
            case artistDetail(ArtistDetail.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: /State.artistDetail, action: /Action.artistDetail) {
                ArtistDetail()
            }
        }
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                
            case .task:
                return .run { send in
                    for try await (data, userFavorites) in Publishers.CombineLatest(
                        eventDataClient.getData(self.eventID),
                        userFavoritesClient.userFavoritesPublisher()
                    ).values {
                        await send(.dataUpdate(data, userFavorites))
                    }
                }
                
            case .dataUpdate(let eventData, let userFavorites):
                
                if let updatedGroupSet = eventData.schedule[id: state.groupSet.id] {
                    state.groupSet = updatedGroupSet
                }
                
                guard case let .groupSet(artistIds) = state.groupSet.type else { return .none }

                
                state.artists = artistIds.compactMap { eventData.artists[id: $0] }.asIdentifedArray
                state.event = eventData.event
                state.stages = eventData.stages
                state.schedule = eventData.schedule
                state.userFavorites = userFavorites
                state.showArtistImages = eventData.artists.contains(where: { $0.imageURL != nil })
                
                return .none
                
            case .didTapScheduleItem(let scheduleItem):
                
                showScheduleItem(scheduleItem.id)
                return .none
                
            case let .didTapArtist(artistID):
                
                state.destination = .artistDetail(
                    ArtistDetail.State(artistID: artistID)
                )
                
                return .none
                
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}
