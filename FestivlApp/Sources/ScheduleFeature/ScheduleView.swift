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
import ScheduleComponents
import FestivlDependencies

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
        WithViewStore(store, observe: Blank.init) { viewStore in
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
    
    struct ViewState: Equatable {
        var deviceOrientation: DeviceOrientation
        @BindingViewState var selectedDate: CalendarDate
        @BindingViewState var showingLandscapeTutorial: Bool
        var festivalDates: [CalendarDate]
        
        init(state: BindingViewStore<ScheduleFeature.State>) {
            self.deviceOrientation = state.deviceOrientation
            self._selectedDate = state.$selectedDate
            self._showingLandscapeTutorial = state.$showingLandscapeTutorial
            self.festivalDates = state.event.festivalDates
        }
    }
    
    public var body: some View {
        WithViewStore(store, observe: ViewState.init ) { viewStore in
            Group {
                switch viewStore.deviceOrientation {
                case .portrait:
                    
                    SingleStageAtOnceView(store: store)
                    
                case .landscape:
                    AllStagesAtOnceView(store: store, date: viewStore.selectedDate)
                }
            }
            .environment(\.calendarSelectedDate, viewStore.selectedDate)
            .toolbarDateSelector(selectedDate: viewStore.$selectedDate)
            .toolbar {
                ToolbarItem {
                    FilterMenu(store: store)
                }
            }
            .sheet(
                store: self.store.scope(state: \.$destination, action: ScheduleFeature.Action.destination),
                state: /ScheduleFeature.Destination.State.artist,
                action: ScheduleFeature.Destination.Action.artist
            ) { store in
                NavigationStack {
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
                isPresenting: viewStore.$showingLandscapeTutorial,
                duration: 5,
                tapToDismiss: true,
                alert: {
                    AlertToast(
                        displayMode: .alert,
                        type: .systemImage("arrow.counterclockwise", .primary),
                        subTitle: "Rotate your phone to see all of the stages at once"
                    )
                },
                completion: {
                    viewStore.send(.scheduleTutorial(.hideLandscapeTutorial))
                }
            )

            .navigationViewStyle(.stack)
            .task { await viewStore.send(.task).finish() }
        }
    }
}




struct FilterMenu: View {
    var store: StoreOf<ScheduleFeature>
    
    var body: some View {
        
        WithViewStore(store, observe: { $0}) { viewStore in
            Menu {
                Toggle(isOn: viewStore.$filteringFavorites.animation()) {
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
            .popover(present: viewStore.$showingFilterTutorial, attributes: { $0.dismissal.mode = .tapOutside }) {
                ArrowPopover(arrowSide: .top(.mostClockwise)) {
                    Text("Filter the schedule to only see your favorite artists")
                }
                .onTapGesture {
                    viewStore.send(.scheduleTutorial(.hideFilterTutorial))
                }
            }
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleLoadingView(
            store: .init(
                initialState: .init(),
                reducer: ScheduleLoadingFeature.init
            )
        )
    }
}
