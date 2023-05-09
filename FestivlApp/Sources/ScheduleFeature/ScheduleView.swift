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
import AlertToast
import Utilities
import Popovers
import Components
import ComposableArchitectureUtilities

enum ScheduleStyle: Equatable {
    case singleStage(Stage)
    case allStages
}

public struct ScheduleLoadingView: View {
    let store: StoreOf<ScheduleLoadingFeature>
    
    public init(store: StoreOf<ScheduleLoadingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            IfLetStore(store.scope(state: \.scheduleState, action: ScheduleLoadingFeature.Action.scheduleAction)) { store in
                ScheduleView(store: store)
            } else: {
                ProgressView()
            }
            .task { await viewStore.send(.task).finish() }
        }
    }
}

public struct ScheduleView: View {
    let store: StoreOf<ScheduleFeature>

    public init(store: StoreOf<ScheduleFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                Group {
                    switch viewStore.deviceOrientation {
                    case .portrait:
                        SingleStageAtOnceView(store: store)
                    case .landscape:
                        AllStagesAtOnceView(store: store)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        EventDaySelector(
                            selectedDate: viewStore.binding(\.$selectedDate),
                            dates: viewStore.event.festivalDates
                        )
                    }

                    ToolbarItem {
                        Menu {
                            Toggle(isOn: viewStore.binding(\.$filteringFavorites)) {
                                Label(
                                    "Favorites",
                                    systemImage:  viewStore.isFiltering ? "heart.fill" : "heart"
                                )
                            }
                        } label: {
                            Label(
                                "Filter",
                                systemImage: viewStore.isFiltering ?
                                    "line.3.horizontal.decrease.circle.fill" :
                                    "line.3.horizontal.decrease.circle"
                            )
                            .if(viewStore.showingFilterTutorial) {
                                $0.colorMultiply(.gray)
                            }
                        }
                        .popover(present: viewStore.binding(\.$showingFilterTutorial), attributes: { $0.dismissal.mode = .tapOutside }) {
                            ArrowPopover(arrowSide: .top(.mostClockwise)) {
                                Text("Filter the schedule to only see your favorite artists")
                            }
                            .onTapGesture {
                                viewStore.send(.scheduleTutorial(.hideFilterTutorial))
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .sheet(
                    store: self.store.scope(state: \.$destination, action: ScheduleFeature.Action.destination),
                    state: /ScheduleFeature.Destination.State.artist,
                    action: ScheduleFeature.Destination.Action.artist
                ) { store in
                    NavigationView {
                        ArtistPageView(store: store)
                    }
                }
                .sheet(
                    store: store.scope(state: \.$destination, action: ScheduleFeature.Action.destination),
                    state: /ScheduleFeature.Destination.State.groupSet,
                    action: ScheduleFeature.Destination.Action.groupSet
                ) {
                    GroupSetDetailView(store: $0)
                }
                .toast(
                    isPresenting: viewStore.binding(\.$showingLandscapeTutorial),
                    duration: 5,
                    tapToDismiss: true,
                    alert: {
                        AlertToast(
                            displayMode: .alert,
                            type: .systemImage("arrow.counterclockwise", .primary),
                            subTitle:
                                """
                                Rotate your phone to see
                                all of the stages at once
                                """
                        )
                    },
                    completion: {
                        viewStore.send(.scheduleTutorial(.hideLandscapeTutorial))
                    }
                )
            }
            .navigationViewStyle(.stack)
            .task { await viewStore.send(.task).finish() }
        }
    }
}

struct EventDaySelector: View {
    @Binding var selectedDate: CalendarDate
    var dates: [CalendarDate]
    
    
    var body: some View {
        Menu {
            ForEach(dates, id: \.self) { date in
                Button {
                    selectedDate = date
                } label: {
                    Text(FestivlFormatting.weekdayFormat(for: date))
                }
            }
        } label: {
            HStack {
                Text(FestivlFormatting.weekdayFormat(for: selectedDate))
                    .font(.title2)
                Image(systemName: "chevron.down")

            }
            .foregroundColor(.primary)
        }
    }
}


struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleLoadingView(store: .init(initialState: .init(), reducer: ScheduleLoadingFeature()))
    }
}


