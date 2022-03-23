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

public struct ManagerEventDashboardView: View {
    let store: Store<ManagerEventDashboardState, ManagerEventDashboardAction>

    public init(store: Store<ManagerEventDashboardState, ManagerEventDashboardAction>) {
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
    let store: Store<ManagerEventDashboardState, ManagerEventDashboardAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Section("Setup") {
                    NavigationLink(
                        destination: ManagerArtistsView(
                            store: store.scope(
                                state: \ManagerEventDashboardState.artistsState,
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
                                state: \ManagerEventDashboardState.stagesState,
                                action: ManagerEventDashboardAction.stagesAction)),
                        tag: SidebarPage.stages,
                        selection: viewStore.binding(\.$sidebarSelection)
                    ) {
                        Label("Stages", systemImage: "mappin.and.ellipse")
                    }

                    NavigationLink(
                        destination: Text("Schedule"),
                        tag: SidebarPage.schedule,
                        selection: viewStore.binding(\.$sidebarSelection)
                    ) {
                        Label("Schedule", systemImage: "calendar")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle(viewStore.event.name)

            Spacer()

            SidebarEventInfoView(store: store)

        }
    }
}

struct SidebarEventInfoView: View {
    let store: Store<ManagerEventDashboardState, ManagerEventDashboardAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Menu(
                content: {
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
                    initialState: .init(
                        event: .testData,
                        artists: Artist.testValues.asIdentifedArray,
                        stages: Stage.testValues.asIdentifedArray,
                        artistSets: ArtistSet.testValues().asIdentifedArray,
                        sidebarSelection: .artists,
                        artistListSelectedArtist: nil,
                        createArtistState: nil,
                        stagesListSelectedStage: nil
                    ),
                    reducer: managerEventDashboardReducer,
                    environment: .init()
                )
            )
                .preferredColorScheme($0)
        }
    }
}
