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

enum ScheduleStyle: Equatable {
    case singleStage(Stage)
    case allStages
}

public struct ScheduleView: View {
    let store: Store<ScheduleState, ScheduleAction>

    public init(store: Store<ScheduleState, ScheduleAction>) {
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
                                    Text(FestivlFormatting.weekdayFormat(for: date))
                                })
                            })
                        } label: {
                            HStack {
                                Text(FestivlFormatting.weekdayFormat(for: viewStore.selectedDate))
                                    .font(.title2)
                                Image(systemName: "chevron.down")

                            }
                            .foregroundColor(.primary)
                        }
                    })

                    ToolbarItem {
                        Menu(content: {
                            Toggle(isOn: viewStore.binding(\.$filteringFavorites), label: {
                                Label(
                                    "Favorites",
                                    systemImage:  viewStore.isFiltering ? "heart.fill" : "heart"
                                )
                            })
                        }, label: {
                            Label(
                                "Filter",
                                systemImage: viewStore.isFiltering ?
                                    "line.3.horizontal.decrease.circle.fill" :
                                    "line.3.horizontal.decrease.circle"
                            )
                            .if(viewStore.showingFilterTutorial, transform: {
                                $0.colorMultiply(.gray)
                            })
                        })
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
                        viewStore.send(.landscapeTutorialHidden)
                    }
                )
            }
            .navigationViewStyle(.stack)
            .onAppear {
                viewStore.send(.onAppear, animation: .default)
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


