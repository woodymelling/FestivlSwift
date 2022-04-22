//
//  ManagerEventDashboardView.swift
//
//
//  Created by Woody on 3/9/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import ManagerArtistsFeature
import StagesFeature
import ManagerScheduleFeature
import AddEditEventFeature
import EventDataFeature

public struct ManagerEventDashboardView: View {
    let store: Store<FestivlManagerEventState, ManagerEventDashboardAction>

    public init(store: Store<FestivlManagerEventState, ManagerEventDashboardAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                if viewStore.sidebarSelection?.isThreeColumn ?? false {
                    NavigationView {
                        Sidebar(store: store)
                        EmptyView()
                        EmptyView()
                    }
                } else {
                    NavigationView {
                        Sidebar(store: store)
                        EmptyView()
                    }
                }
            }
        }
    }
}

struct Sidebar: View {
    let store: Store<FestivlManagerEventState, ManagerEventDashboardAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Section("Setup") {
                    NavigationLink(
                        destination: ManagerScheduleView(
                            store: store.scope(
                                state: \FestivlManagerEventState.scheduleState,
                                action: ManagerEventDashboardAction.scheduleAction
                            )
                        ),
                        tag: SidebarPage.schedule,
                        selection: viewStore.binding(\.$sidebarSelection)
                    ) {
                        Label("Schedule", systemImage: "calendar")
                    }

                    NavigationLink(
                        destination: ManagerArtistsView(
                            store: store.scope(
                                state: \FestivlManagerEventState.artistsState,
                                action: ManagerEventDashboardAction.artistsAction
                            )
                        ),
                        tag: SidebarPage.artists,
                        selection: viewStore.binding(\.$sidebarSelection)
                    ) {
                        Label("Artists", systemImage: "person.2")
                    }

                    NavigationLink(
                        destination: StagesView(
                            store: store.scope(
                                state: \FestivlManagerEventState.stagesState,
                                action: ManagerEventDashboardAction.stagesAction)),
                        tag: SidebarPage.stages,
                        selection: viewStore.binding(\.$sidebarSelection)
                    ) {
                        Label("Stages", systemImage: "mappin.and.ellipse")
                    }


                }

                NavigationLink(
                    destination: EventDataView(
                        store: store.scope(
                            state: \FestivlManagerEventState.eventDataState,
                            action: ManagerEventDashboardAction.eventDataAction
                        )
                    ),
                    tag: SidebarPage.eventData,
                    selection: viewStore.binding(\.$sidebarSelection)
                ) {
                    Label("Other Event Data", systemImage: "calendar.circle")
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle(viewStore.event.name)

            Spacer()

            SidebarEventInfoView(store: store)

        }
        .sheet(
            scoping: store,
            state: \.$editEventState,
            action: ManagerEventDashboardAction.editEventAction,
            then: AddEditEventView.init
        )
    }
}

struct SidebarEventInfoView: View {
    let store: Store<FestivlManagerEventState, ManagerEventDashboardAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Menu(
                content: {
                    Button(action: { viewStore.send(.editEvent)}, label: {
                        Label("Edit \(viewStore.event.name)", systemImage: "pencil")
                    })

                    Button(role: .destructive, action: {
                        viewStore.send(.exitEvent)
                    }, label: {
                        Label("Exit \(viewStore.event.name)", systemImage: "xmark")
                    })
                    
                },
                label: {
                    Text(viewStore.event.name)
                        .lineLimit(1)
                })
            .menuStyle(.borderlessButton)
            .padding()
        }
    }
}

struct ManagerEventDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            ManagerEventDashboardView(
                store: .init(
                    initialState: .init(event: .testData),
                    reducer: managerEventDashboardReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
