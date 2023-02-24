//
// GroupSetDetailDomain.swift
//
//
//  Created by Woody on 4/16/2022.
//

import ComposableArchitecture
import Models
import ArtistPageFeature
import FestivlDependencies
import Combine


public struct GroupSetDetail: ReducerProtocol {
    
    public init() {}
    
    @Dependency(\.eventID) var eventID
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.userFavoritesClient) var userFavoritesClient
    
    public struct State: Equatable, Identifiable {
        public init(groupSet: ScheduleItem) {
            self.groupSet = groupSet
        }

        public var groupSet: ScheduleItem
        public var event: Event?
        public var schedule: Schedule?
        public var stages: IdentifiedArrayOf<Stage> = .init()

        public var id: ScheduleItem.ID {
            groupSet.id
        }

        public var artistDetailStates: IdentifiedArrayOf<ArtistPage.State> = .init()
    }
    
    public enum Action {
        case task
        case dataUpdate(EventData, UserFavorites)
        
        case didTapScheduleItem(ScheduleItem)

        case artistDetailAction(id: Artist.ID, ArtistPage.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                
            case .task:
                return .run { send in
                    for try await (data, userFavorites) in Publishers.CombineLatest(
                        eventDataClient.getData(eventID.value),
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

                
                let artists = artistIds.compactMap { eventData.artists[id: $0] }
                
                state.artistDetailStates = artists.map {
                    ArtistPage.State(
                        artistID: $0.id,
                        artist: $0,
                        event: eventData.event,
                        schedule: eventData.schedule,
                        stages: eventData.stages,
                        isFavorite: userFavorites.contains($0.id) // TODO: Fix this
                    )
                    
                }.asIdentifedArray
                
                state.event = eventData.event
                state.stages = eventData.stages
                state.schedule = eventData.schedule
                
                return .none
                
            case .didTapScheduleItem:
                return .none
                
            case .artistDetailAction:
                return .none
            }
        }
        .forEach(\.artistDetailStates, action: /Action.artistDetailAction) {
            ArtistPage()
        }
    }
}
