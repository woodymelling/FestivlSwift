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


extension ScheduleItem: TimelineCard {
    public var horizontalGrouping: Int { return stage.sortIndex }
}

public struct ScheduleLoadingView: View {
    let store: StoreOf<ScheduleLoadingFeature>
    
    public init(store: StoreOf<ScheduleLoadingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: Blank.init) { viewStore in
            let _ = Self._printChanges()
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
        var selectedDate: CalendarDate
        var showingLandscapeTutorial: Bool
        var festivalDates: [CalendarDate]
        
        init(state: ScheduleFeature.State) {
            self.deviceOrientation = state.deviceOrientation
            self.selectedDate = state.selectedDate
            self.showingLandscapeTutorial = state.showingLandscapeTutorial
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
//            .environment(\.calendarSelectedDate, viewStore.selectedDate)
            .toolbarDateSelector(
                selectedDate: viewStore.binding(
                    get: { $0.selectedDate },
                    send: { .binding(.set(\.$selectedDate, $0)) }
                ).animation(),
                dates: viewStore.festivalDates
            )
            .toolbar {
                ToolbarItem {
                    FilterMenu(store: store)
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
                isPresenting: viewStore.binding(
                    get: { $0.showingLandscapeTutorial },
                    send: { .binding(.set(\.$showingLandscapeTutorial, $0))}
                ),
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


extension View {
    func toolbarDateSelector(selectedDate: Binding<CalendarDate>, dates: [CalendarDate]) -> some View {
        self.modifier(ToolbarDateSelectorViewModifier(selectedDate: selectedDate, dates: dates))
    }
}
struct ToolbarDateSelectorViewModifier: ViewModifier {
    
    @Binding var selectedDate: CalendarDate
    var dates: [CalendarDate]
    
    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content
                .navigationTitle(Text(FestivlFormatting.weekdayFormat(for: selectedDate)))
                .toolbarTitleMenu {
                    ForEach(dates, id: \.self) { date in
                        Button {
                            selectedDate = date
                        } label: {
                            Text(FestivlFormatting.weekdayFormat(for: date))
                        }
                    }
                }
        } else {
            content
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        EventDaySelector(
                            selectedDate: $selectedDate, dates: dates)
                    }
                }
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

struct FilterMenu: View {
    var store: StoreOf<ScheduleFeature>
    
    var body: some View {
        
        WithViewStore(store, observe: { $0}) { viewStore in
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
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleLoadingView(store: .init(initialState: .init(), reducer: ScheduleLoadingFeature()))
    }
}


//struct SelectedCardEnvironmentKey: EnvironmentKey {
//    static var defaultValue: ScheduleItem.ID? = nil
//    
//    
//}
