//
//  Schedule.swift
//
//
//  Created by Woody on 2/18/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import ArtistPageFeature
import GroupSetDetailFeature

enum ScheduleStyle: Equatable {
    case singleStage(Stage)
    case allStages
}

public struct ScheduleView: View {
    let store: Store<ScheduleState, ScheduleAction>
    @State var showing: Bool = false

    public init(store: Store<ScheduleState, ScheduleAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Group {
                    switch viewStore.deviceOrientation {
                    case .portrait:
                        SingleStageAtOnceView(store: store)
                    case .landscape:
                        AllStagesAtOnceView(store: store)
                    }
                }
                .sheet(
                    scoping: store,
                    state: \.$selectedArtistState,
                    action: ScheduleAction.artistPageAction,
                    then: { artistStore in
                        NavigationView {
                            ArtistPageView(store: artistStore)
                        }
                    }
                )
                .sheet(
                    scoping: store,
                    state: \.$selectedGroupSetState,
                    action: ScheduleAction.groupSetDetailAction,
                    then: GroupSetDetailView.init
                )
                .toolbar {
                    ToolbarItem(placement: .principal, content: {
                        Menu {
                            ForEach(viewStore.event.festivalDates, id: \.self, content: { date in
                                Button(action: {
                                    viewStore.send(.selectedDate(date), animation: .default)
                                }, label: {
                                    Text(date.formatted(.dateTime.weekday(.wide)))
                                })
                            })
                        } label: {
                            HStack {
                                Text(viewStore.selectedDate.formatted(.dateTime.weekday(.wide)))
                                    .font(.title2)
                                Image(systemName: "chevron.down")

                            }
                            .foregroundColor(.primary)
                        }
                    })
                }
                .navigationBarTitleDisplayMode(.inline)

            }
            .navigationViewStyle(.stack)
            .onAppear {
                viewStore.send(.subscribeToDataPublishers)
            }
        }


    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            //            let time = Event.testData.festivalDates[0]
            ScheduleView(
                store: .testStore
            )
            .preferredColorScheme($0)
        }
    }
}


