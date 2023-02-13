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
    
    @Dependency(\.eventID) var eventID
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.userFavoritesClient) var userFavoritesClient
    
    public struct State: Equatable {

        public var event: Event?
        public var artistStates: IdentifiedArrayOf<ArtistPage.State> = .init()
        public var schedule: Schedule?
        public var stages: IdentifiedArrayOf<Stage>?
        
        var showArtistImages: Bool = false
        
        @BindingState public var searchText: String = ""
        
        var isLoading: Bool = false
        
        var filteredArtistStates: IdentifiedArrayOf<ArtistPage.State> {
            artistStates.filterForSearchTerm(searchText).asIdentifedArray
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(_ action: BindingAction<State>)
        case artistDetail(id: Artist.ID, action: ArtistPage.Action)
        case task
        
        case dataUpdate(EventData, UserFavorites)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding, .artistDetail:
                return .none
            case .task:
                return .run { send in
                    
                    for try await (data, userFavorites) in Publishers.CombineLatest(
                        eventDataClient.getData(eventID.value),
                        userFavoritesClient.userFavoritesPublisher()
                    ).values {
                        await send(.dataUpdate(data, userFavorites))
                    }
                } catch: { _, _ in
                    print("Artist Page Loading error")
                }
                
            case .dataUpdate(let eventData, let userFavorites):
                state.artistStates = eventData.artists
                    .sorted(by: \.name)
                    .map {
                        ArtistPage.State(
                            artistID: $0.id,
                            artist: $0,
                            event: eventData.event,
                            schedule: eventData.schedule,
                            stages: eventData.stages,
                            isFavorite: userFavorites.contains($0.id)
                        )
                    }
                    .asIdentifedArray
                
                state.schedule = eventData.schedule
                state.event = eventData.event
                state.stages = eventData.stages
                
                state.showArtistImages = eventData.artists.contains(where: { $0.imageURL != nil })
                
                return .none
                

            }
        }
        .forEach(\.artistStates, action: /Action.artistDetail) {
            ArtistPage()
        }
    }
}
