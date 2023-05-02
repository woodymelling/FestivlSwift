//
//  Explore.swift
//
//
//  Created by Woody on 3/2/2022.
//

import ComposableArchitecture
import Models
import ArtistPageFeature
import Combine
import FestivlDependencies

public struct ExploreFeature: ReducerProtocol {
    public init() {}
    
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.eventID.value) var eventID

    
    public struct State: Equatable {

        public var event: Event?
        public var artistStates: IdentifiedArrayOf<ArtistDetail.State> = .init()
        public var schedule: Schedule?
        public var stages: IdentifiedArrayOf<Stage>?
        
        @BindingState var selectedArtistPageState: ArtistDetail.State?
        
        var isLoading: Bool = false
        
        public init() {}
    }

    public enum Action: BindableAction {
        case binding(_ action: BindingAction<State>)
        
        case task
        case dataUpdate(EventData)
        
        case artistDetail(id: Artist.ID, action: ArtistDetail.Action)
        
        case didTapArtist(ArtistDetail.State)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding, .artistDetail:
                return .none
            case .task:
                return .run { send in
                    for try await data in eventDataClient.getData(eventID).values {
                        await send(.dataUpdate(data))
                    }
                } catch: { _, _ in
                    print("Artist Page Loading error")
                }
                
            case .dataUpdate(let eventData):
                state.artistStates = eventData.artists
                    .filter { $0.imageURL != nil }
                    .map {
                        ArtistDetail.State(
                            artistID: $0.id,
                            artist: $0,
                            event: eventData.event,
                            schedule: eventData.schedule,
                            stages: eventData.stages,
                            isFavorite: false
                        )
                    }
                    .asIdentifedArray
                
                state.schedule = eventData.schedule
                state.event = eventData.event
                state.stages = eventData.stages
                
                return .none
                
            case .didTapArtist(let artistPageState):
                state.selectedArtistPageState = artistPageState
                return .none
            }
        }
        .forEach(\.artistStates, action: /Action.artistDetail) {
            ArtistDetail()
        }
    }
    
    func shuffleArtistStates(artistPageState: inout IdentifiedArrayOf<ArtistDetail.State>) {
        artistPageState.shuffle()
    }
    
    
}

extension Set {
    mutating func toggle(item: Element) {
        if contains(item) {
            remove(item)
        } else {
            insert(item)
        }
    }
}
