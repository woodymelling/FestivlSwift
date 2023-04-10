//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 2/24/23.
//

import SwiftUI
import ComposableArchitecture
import Models
import Components

struct ManagerEventListView: View {
    let store: StoreOf<ManagerEventListDomain>
    
    struct ViewState: Equatable {
        var events: IdentifiedArrayOf<Event>
        var searchText: String
        var isLoading: Bool
        
        init(_ state: ManagerEventListDomain.State) {
            events = state.events
            searchText = state.searchText
            isLoading = state.isLoading
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationView {
                
                
                SimpleSearchableList(
                    data: viewStore.events,
                    searchText: viewStore.binding(
                        get: { $0.searchText },
                        send: { ManagerEventListDomain.Action.searchTextDidChange($0) }
                    ),
                    isLoading: viewStore.isLoading
                ) { event in
//                    Text(event.name)
                    ZStack {
                        NavigationLink(destination: { EmptyView() }, label: { EmptyView() })
                        HStack(spacing: 10) {
                            CachedAsyncImage(
                                url: event.imageURL,
                                placeholder: {
                                    Image(systemName: "calendar.circle.fill")
                                        .resizable()
                                }
                            )
                            .frame(width: 60, height: 60)

                            VStack(alignment: .leading) {
                                Text(event.name)
                                Text(FestivlFormatting.dateIntervalFormat(startDate: event.startDate, endDate: event.endDate))
                                    .lineLimit(1)
                                    .font(.caption2)
                            }

                            Spacer()
                        }
                    }
                }
                .navigationBarTitle("Events")
                .toolbar {
                    Button {
                        viewStore.send(.addEventButtonTapped)
                    } label: {
                        Label("Add Event button", systemImage: "plus")
                    }
                    .labelStyle(.iconOnly)
                }
            }
            .task { await viewStore.send(.task).finish() }
        }
       
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerEventListView(
            store: .init(
                initialState: .init(),
                reducer: ManagerEventListDomain()
            )
        )
    }
}
