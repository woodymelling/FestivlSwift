//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/30/22.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import AddEditArtistSetFeature

public struct ManagerScheduleView: View {
    public init(store: Store<ManagerScheduleState, ManagerScheduleAction>) {
        self.store = store
    }

    let store: Store<ManagerScheduleState, ManagerScheduleAction>

    public var body: some View {
        WithViewStore(store) { viewStore in
            ManagerTimelineView(store: store)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button(action: {
                            viewStore.send(.addEditArtistSetButtonPressed)
                        }, label: {
                            Label("Add Stage", systemImage: "plus")
                                .labelStyle(.iconOnly)
                        })
                    }
                }
                .sheet(item: viewStore.binding(\ManagerScheduleState.$addEditArtistSetState)) { _ in
                    IfLetStore(
                        store.scope(
                            state: \ManagerScheduleState.addEditArtistSetState,
                            action: ManagerScheduleAction.addEditArtistSetAction
                        ),
                        then: AddEditArtistSetView.init
                    )
                }
        }
        
    }
}

struct ManagerScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ManagerScheduleView(
                store: .previewStore
            )
            .preferredColorScheme($0)
        }
    }
}
