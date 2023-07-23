//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 7/3/23.
//

import SwiftUI
import ComposableArchitecture
import Components

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
                    useNativeSearchBar: false
                ) { artist in
                    Text(artist.name)
                        .lineLimit(1)
                }
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
                reducer: ScheduleArtistListDomain())
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
