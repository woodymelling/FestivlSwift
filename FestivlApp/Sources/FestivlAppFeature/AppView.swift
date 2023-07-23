//
//  App.swift
//
//
//  Created by Woody on 2/11/2022.
//

import SwiftUI
import ComposableArchitecture
import EventListFeature
import EventFeature


public struct AppView: View {
    let store: StoreOf<AppFeature>


    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        
        
        
        IfLetStore(
            store.scope(state: \.eventState, action: AppFeature.Action.eventAction),
            then: EventView.init(store:),
            else: {
                EventListView(
                    store: store.scope(state: \.eventListState, action: AppFeature.Action.eventListAction)
                )
            }
        )
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(store: .init(initialState: .init(), reducer: AppFeature()))
    }
}
