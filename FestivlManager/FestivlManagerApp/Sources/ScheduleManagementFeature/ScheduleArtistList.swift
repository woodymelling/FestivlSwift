//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/3/23.
//

import Foundation
import ComposableArchitecture
import Models
import SwiftUI
import Components


@Reducer
public struct ScheduleArtistListDomain {
    
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


struct ScheduleArtistListView: View {
    let store: StoreOf<ScheduleArtistListDomain>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in

            VStack(spacing: 0) {
                SearchTextField(text: viewStore.$searchText)
                    .padding(.horizontal)
                    .padding(.bottom)

                SimpleSearchableList(
                    data: viewStore.artists,
                    searchText: viewStore.$searchText,
                    isLoading: viewStore.isLoading
                ) { artist in
                    Text(artist.name)
                        .lineLimit(1)
                }
                .useNativeSearchBar(false)
                .listStyle(.plain)
            }
            .task { await viewStore.send(.task).finish() }
        }
    }
}

#Preview {
    HStack {
        ScheduleArtistListView(
            store: .init(
                initialState: .init(),
                reducer: ScheduleArtistListDomain.init
            )
        )
        .frame(width: 200)

        Spacer()
    }
}

struct SearchTextField: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $text)
        }
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .stroke()
                .foregroundStyle(.placeholder)
        }
    }
}
