//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/3/23.
//

import Foundation
import ComposableArchitecture
import Models


public struct ScheduleArtistListDomain: Reducer {
    
    @Dependency(\.artistClient) var artistsClient
    
    public struct State: Equatable {
        @BindingState var searchText: String = ""
        
        var isLoading: Bool = false
        
        var artists: IdentifiedArrayOf<Artist> = []
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(_ action: BindingAction<State>)
        case task
        
        case artistsListUpdate(IdentifiedArrayOf<Artist>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .task:
                state.isLoading = true
                return .run { send in
                    for try await artists in artistsClient.getArtists().values {
                        await send(.artistsListUpdate(artists))
                    }
                }
            case .artistsListUpdate(let artistList):
                state.isLoading = false
                state.artists = artistList
                return .none
            }
        }
    }
}
