//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 7/4/23.
//

import SwiftUI
import ComposableArchitecture

public struct ScheduleManagementView: View {
    
    public init(store: StoreOf<ScheduleManagementDomain>) {
        self.store = store
    }
    
    let store: StoreOf<ScheduleManagementDomain>
    
    @Dependency(\.eventID) var eventID
    
    struct ViewState: Equatable {
        var presentingArtistList: Bool

        init(_ state: ScheduleManagementDomain.State) {
            presentingArtistList = state.presentingArtistList
        }
    }
    
    public var body: some View {
        WithViewStore(store, observe: ViewState.init ) { viewStore in
            IfLetStore(scheduleStore) {
                ScheduleView(store: $0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            }
            .leadingSidebar(isPresented: viewStore.presentingArtistList) {
                ScheduleArtistListView(store: artistListStore)
            }
            .task { await viewStore.send(.task).finish() }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Artists", systemImage: "person.3") {
                        viewStore.send(.didTapArtistListToggle)
                    }
                    .symbolVariant(viewStore.presentingArtistList ? .fill : .none)
                }
            }
             
        }
    }
    
    var scheduleStore: Store<ScheduleDomain.State?, ScheduleDomain.Action> {
        store.scope(
            state: \.scheduleState,
            action: ScheduleManagementDomain.Action.scheduleAction
        )
    }
    
    var artistListStore: StoreOf<ScheduleArtistListDomain> {
        store.scope(
            state: \.artistListState,
            action: ScheduleManagementDomain.Action.artistListAction
        )
    }
}


// MARK: - Preview
#Preview("Main Schedule") {
    NavigationStack {
        ScheduleManagementView(
            store: Store(
                initialState: .init()
            ) {
                ScheduleManagementDomain()
            }
        )
    }
    .environment(\.stages, .previewData)
}
