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
            HStack {

                
                ScheduleArtistList(store: store)
                    .padding(.top, 50)

                Divider()
                    .padding(.top, 50)

                ManagerTimelineView(store: store)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if viewStore.loading {
                        ProgressView()
                    }

                    Button(action: {
                        viewStore.send(.addEditArtistSetButtonPressed)
                    }, label: {
                        Label("Add Artist Set", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    })

                    if viewStore.hasUnpublishedChanges {
                        Label("Unpublished Changes", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .labelStyle(.titleAndIcon)
                    }
                  
                    Button("Publish", action: {
                        viewStore.send(.publishChanges)
                    })
                    
                    Button("Adjust TimeZones", action: {
                        viewStore.send(.adjustTimeZone)
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
