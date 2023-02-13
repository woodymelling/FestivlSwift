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

public struct ExploreFeature: ReducerProtocol {
    public init() {}
    
    @Dependency(\.stageClient) var stageClient
    @Dependency(\.artistClient) var artistClient
    @Dependency(\.scheduleClient) var scheduleClient
    @Dependency(\.eventID) var eventID
    @Dependency(\.eventClient) var eventClient
    
    public struct State: Equatable {

        public var event: Event?
        public var artistStates: IdentifiedArrayOf<ArtistPage.State> = .init()
        public var schedule: Schedule?
        public var stages: IdentifiedArrayOf<Stage>?
        
        @BindingState var selectedArtistPageState: ArtistPage.State?
        
        var isLoading: Bool = false
        
        public init() {}
    }

    public enum Action: BindableAction {
        case binding(_ action: BindingAction<State>)
        
        case task
        case dataUpdate((IdentifiedArrayOf<Artist>, Schedule, Event, IdentifiedArrayOf<Stage>))
        
        case artistDetail(id: Artist.ID, action: ArtistPage.Action)
        
        case didTapArtist(ArtistPage.State)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding, .artistDetail:
                return .none
            case .task:
                return .run { send in
                    for try await data in Publishers.CombineLatest4(
                        artistClient.getArtists(eventID.value),
                        scheduleClient.getSchedule(eventID.value),
                        eventClient.getEvent(eventID.value),
                        stageClient.getStages(eventID.value)
                    ).values {
                        await send(.dataUpdate(data))
                    }
                } catch: { _, _ in
                    print("Artist Page Loading error")
                }
                
            case .dataUpdate((let artists, let schedule, let event, let stages)):
                state.artistStates = artists
                    .filter { $0.imageURL != nil }
                    .map {
                        ArtistPage.State(
                            artistID: $0.id,
                            artist: $0,
                            event: event,
                            schedule: schedule,
                            stages: stages,
                            isFavorite: false
                        )
                    }
                    .asIdentifedArray
                
                state.schedule = schedule
                state.event = event
                state.stages = stages
                
                return .none
                
            case .didTapArtist(let artistPageState):
                state.selectedArtistPageState = artistPageState
                return .none
            }
        }
        .forEach(\.artistStates, action: /Action.artistDetail) {
            ArtistPage()
        }
    }
    
    func shuffleArtistStates(artistPageState: inout IdentifiedArrayOf<ArtistPage.State>) {
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
