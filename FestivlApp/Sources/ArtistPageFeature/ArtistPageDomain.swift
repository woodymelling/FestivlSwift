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
    
    @Dependency(\.stageClient) var stageClient
    @Dependency(\.artistClient) var artistClient
    @Dependency(\.scheduleClient) var scheduleClient
    @Dependency(\.eventID) var eventID
    @Dependency(\.eventClient) var eventClient
    
    public init() {}
    
    public struct State: Equatable {
        
        var artist: Artist?
        var event: Event?
        var schedule: Schedule?
        var stages: IdentifiedArrayOf<Stage>?
        var artistID: Artist.ID

        public var isFavorite: Bool = false

        public init(_ artistID: Artist.ID) {
            self.artistID = artistID
        }
    }
    
    public enum Action {
        case task
        case didTapScheduleItem(ScheduleItem)
        case favoriteArtistButtonTapped
        
        case dataUpdate((Artist, Schedule, Event, IdentifiedArrayOf<Stage>))
    }
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .didTapScheduleItem:
            return .none
        case .favoriteArtistButtonTapped:
            state.isFavorite.toggle()
            return .none

        case .task:
            return .run { [state] send in
                
                for try await data in Publishers.CombineLatest4(
                    artistClient.getArtist(eventID, state.artistID),
                    scheduleClient.getSchedule(eventID),
                    eventClient.getEvent(eventID),
                    stageClient.getStages(eventID)
                ).values {
                    await send(.dataUpdate(data))
                }
            } catch: { _, _ in
                print("Artist Page Loading error")
            }
            
        case .dataUpdate((let artist, let schedule, let event, let stages)):
            state.artist = artist
            state.schedule = schedule
            state.event = event
            state.stages = stages
            
            return .none
        }
    }
}

//
//public extension ArtistPage.State {
//    static func fromArtistList(
//        _ artists: IdentifiedArrayOf<Artist>,
//        schedule: Schedule,
//        event: Event,
//        stages: IdentifiedArrayOf<Stage>,
//        favoriteArtists: Set<ArtistID>
//
//    ) -> IdentifiedArrayOf<ArtistPage.State> {
//        // Set the artistStates and their sets in two passes so that it's O(A + S) instead of O(A*S)
//        var artistStates = IdentifiedArray(uniqueElements: artists.map { artist in
//            ArtistPage.State(
//                artist: artist,
//                event: event,
//                setsForArtist: .init(),
//                stages: stages,
//                isFavorite: favoriteArtists.contains(artist.id!)
//            )
//        })
//
//        for scheduleItem in schedule.values.joined() {
//            switch scheduleItem.type {
//            case .artistSet(let artistID):
//                artistStates[id: artistID]?.sets.append(scheduleItem)
//
//            case .groupSet(let artistIDs):
//                artistIDs.forEach {
//                    artistStates[id: $0]?.sets.append(scheduleItem)
//                }
//            }
//        }
//
//        return artistStates
//    }
//}
//
//extension ArtistPage.State: Searchable {
//    public var searchTerms: [String] {
//        return [artist.name]
//    }
//}

//public func combineLatest<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence, Base4>(_ base1: Base1, _ base2: Base2, _ base3: Base3) -> AsyncCombineLatest3Sequence<Base1, Base2, Base3>

