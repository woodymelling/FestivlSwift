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

public struct ArtistListFeature: Reducer {
    public init() {}
    
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.userFavoritesClient) var userFavoritesClient
    
    public struct State: Equatable {
        public var event: Event?
        public var artists: IdentifiedArrayOf<Artist> = .init()
        public var schedule: Schedule?
        public var stages: IdentifiedArrayOf<Stage>?
        
        @PresentationState var artistDetail: ArtistDetail.State?
        
        @BindingState public var searchText: String = ""
        
        var showArtistImages: Bool = false
        var isLoading: Bool = false
        
        var userFavorites: UserFavorites = .init()
        
        var filteredArtists: [Artist] {
            artists.filterForSearchTerm(searchText)
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(_ action: BindingAction<State>)
        case task
        
        case artistDetail(PresentationAction<ArtistDetail.Action>)
        case dataUpdate(EventData, UserFavorites)
        
        case didTapArtist(Artist.ID)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding, .artistDetail:
                return .none
            case .task:
                return .run { send in
                    
                    for try await (data, userFavorites) in Publishers.CombineLatest(
                        eventDataClient.getData(),
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
                
                state.artistDetail = ArtistDetail.State(artistID: artistID)
                
                return .none
            }
        }
        .ifLet(\.$artistDetail, action: /Action.artistDetail) {
            ArtistDetail()
        }
    }
}
