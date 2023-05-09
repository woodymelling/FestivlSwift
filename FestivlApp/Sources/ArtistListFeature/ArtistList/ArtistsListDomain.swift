//
//  ArtistList.swift
//
//
//  Created by Woody on 2/9/2022.
//

import ComposableArchitecture
import Models
import Utilities
import FestivlDependencies
import Combine
import ArtistPageFeature

extension Artist: Searchable {
    public var searchTerms: [String] {
        [name]
    }
}

public struct ArtistListFeature: ReducerProtocol {
    public init() {}
    
    @Dependency(\.userDefaults.eventID) var eventID
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.userFavoritesClient) var userFavoritesClient
    
    public struct State: Equatable {
        public var event: Event?
        public var artists: IdentifiedArrayOf<Artist> = .init()
        public var schedule: Schedule?
        public var stages: IdentifiedArrayOf<Stage>?
        
        @PresentationState var destination: Destination.State?
        
        var showArtistImages: Bool = false
        @BindingState public var searchText: String = ""
        var isLoading: Bool = false
        
        var userFavorites: UserFavorites = .init()
        
        var filteredArtists: [Artist] {
            artists.filterForSearchTerm(searchText)
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(_ action: BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case task
        
        case dataUpdate(EventData, UserFavorites)
        
        case didTapArtist(Artist.ID)
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
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding, .destination:
                return .none
            case .task:
                return .run { send in
                    
                    for try await (data, userFavorites) in Publishers.CombineLatest(
                        eventDataClient.getData(eventID),
                        userFavoritesClient.userFavoritesPublisher()
                    ).values {
                        await send(.dataUpdate(data, userFavorites))
                    }
                } catch: { _, _ in
                    print("Artist Page Loading error")
                }
                
            case .dataUpdate(let eventData, let userFavorites):
                state.artists = eventData.artists
                state.schedule = eventData.schedule
                state.event = eventData.event
                state.stages = eventData.stages
                
                state.showArtistImages = eventData.artists.contains(where: { $0.imageURL != nil })
                
                state.userFavorites = userFavorites
                
                return .none
                
            case let .didTapArtist(artistID):
                
                state.destination = .artistDetail(
                    ArtistDetail.State(artistID: artistID)
                )
                
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}
