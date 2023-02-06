//
//  ArtistPage.swift
//
//
//  Created by Woody on 2/13/2022.
//

import ComposableArchitecture
import Models
import IdentifiedCollections
import Utilities
import FestivlDependencies
import Combine


public struct ArtistPage: ReducerProtocol {
    @Dependency(\.eventID) var eventID
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.userFavoritesClient) var userFavoritesClient
    
    public init() {}
    
    public struct State: Equatable, Identifiable {
        
        public var artistID: Artist.ID
        public var artist: Artist?
        public var event: Event?
        public var schedule: Schedule?
        public var stages: IdentifiedArrayOf<Stage>?
        
        public var id: Artist.ID { artistID }
        public var isFavorite: Bool

        public init(artistID: Artist.ID, artist: Artist? = nil, event: Event? = nil, schedule: Schedule? = nil, stages: IdentifiedArrayOf<Stage>? = nil, isFavorite: Bool) {
            self.artist = artist
            self.event = event
            self.schedule = schedule
            self.stages = stages
            self.artistID = artistID
            self.isFavorite = isFavorite
        }
    }
    
    public enum Action {
        case task
        case dataUpdate(EventData, Bool)
        
        case didTapScheduleItem(ScheduleItem)
        case favoriteArtistButtonTapped
    }
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .didTapScheduleItem:
            return .none
            
        case .favoriteArtistButtonTapped:
            userFavoritesClient.toggleArtistFavorite(state.artistID)
            return .none

        case .task:
            
            return .run { [state] send in
                
                for try await (data, artistIsFavorited) in Publishers.CombineLatest(
                    eventDataClient.getData(eventID.value),
                    userFavoritesClient.userFavoritesPublisher().map { $0.contains(state.artistID) }
                ).values {
                    await send(.dataUpdate(data, artistIsFavorited))
                }
            } catch: { _, _ in
                print("Artist Page Loading error")
            }
            
        case .dataUpdate(let eventData, let artistIsFavorited):
            state.artist = eventData.artists[id: state.artistID]
            state.schedule = eventData.schedule
            state.event = eventData.event
            state.stages = eventData.stages
            state.isFavorite = artistIsFavorited
            
            return .none
        }
    }
}

extension ArtistPage.State: Searchable {
    public var searchTerms: [String] {
        if let artist {
            return [artist.name]
        } else {
            return []
        }
    }
}
