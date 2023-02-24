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
    @State var showing: Bool = true

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
                    action: ScheduleFeature.Action.artistPageAction,
                    then: { artistStore in
                        NavigationView {
                            ArtistPageView(store: artistStore)
                        }
                    }
                )
                .sheet(
                    scoping: store,
                    state: \.$selectedGroupSetState,
                    action: ScheduleFeature.Action.groupSetDetailAction,
                    then: GroupSetDetailView.init
                )
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Menu {
                            ForEach(viewStore.event.festivalDates, id: \.self, content: { date in
                                Button {
                                    viewStore.send(.selectedDate(date), animation: .default)
                                } label: {
                                    Text(FestivlFormatting.weekdayFormat(for: date))
                                }
                            })
                        } label: {
                            HStack {
                                Text(FestivlFormatting.weekdayFormat(for: viewStore.selectedDate))
                                    .font(.title2)
                                Image(systemName: "chevron.down")

                            }
                            .foregroundColor(.primary)
                        }
                    }

                    ToolbarItem {
                        Menu {
                            Toggle(isOn: viewStore.binding(\.$filteringFavorites), label: {
                                Label(
                                    "Favorites",
                                    systemImage:  viewStore.isFiltering ? "heart.fill" : "heart"
                                )
                            })
                        } label: {
                            Label(
                                "Filter",
                                systemImage: viewStore.isFiltering ?
                                    "line.3.horizontal.decrease.circle.fill" :
                                    "line.3.horizontal.decrease.circle"
                            )
                            .if(viewStore.showingFilterTutorial, transform: {
                                $0.colorMultiply(.gray)
                            })
                        }
                        .popover(present: viewStore.binding(\.$showingFilterTutorial), attributes: { $0.dismissal.mode = .tapOutside }) {
                            ArrowPopover(arrowSide: .top(.mostClockwise)) {
                                Text("Filter the schedule to only see your favorite artists")
                            }
                            .onTapGesture {
                                viewStore.send(.binding(.set(\.$showingFilterTutorial, false)))
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
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
                        viewStore.send(.hideLandscapeTutorial)
                    }
                )
            }
            .navigationViewStyle(.stack)
            .task { await viewStore.send(.task).finish() }
        }
    }
}


struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleLoadingView(store: .init(initialState: .init(), reducer: ScheduleLoadingFeature()))
    }
}


