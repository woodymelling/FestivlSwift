//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/22/23.
//

import SwiftUI
import ComposableArchitecture
import ScheduleComponents
import Models
import Utilities

public struct WorkshopsView: View {
    public init(store: StoreOf<WorkshopsFeature>) {
        self.store = store
    }
    
    let store: StoreOf<WorkshopsFeature>
    
    @Environment(\.event) var event
    
    
    struct ViewState: Equatable {
        var workshops:  IdentifiedArrayOf<Workshop>
        var selectedDate: CalendarDate
        var selectedWorkshop: Workshop?
        
        init(state: WorkshopsFeature.State) {
            self.workshops = state.workshops[state.selectedDate] ?? []
            self.selectedDate = state.selectedDate
            self.selectedWorkshop = state.selectedWorkshop
        }
    }
    
    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ScrollViewReader { proxy in
                ScrollView {
                    SchedulePageView(viewStore.workshops) { workshop in
                        WorkshopCard(workshop: workshop)
                            .onTapGesture {
                                viewStore.send(.didTapWorkshop(workshop))
                            }
                    }
                }
                .task {
                    proxy.scrollTo(ScheduleHourTag(hour: 12), anchor: .center)
                }
            }
            .task { await viewStore.send(.task).finish() }
            .toolbarDateSelector(
                selectedDate: viewStore.binding(
                    get: { $0.selectedDate },
                    send: { .didSelectDay($0) }
                )
                .animation()
            )
            .environment(\.dayStartsAtNoon, false) //
            .environment(\.calendarSelectedDate, viewStore.selectedDate)
            .sheet(
                item: viewStore.binding(
                    get: \.selectedWorkshop,
                    send: { .binding(.set(\.$selectedWorkshop, $0)) }
                ),
                content: WorkshopDetailsView.init
            )
        }
    }
}

extension Workshop: TimeRangeRepresentable {
    public var timeRange: Range<Date> {
        startTime..<endTime
    }
}

struct WorkshopCard: View {
    var workshop: Workshop
    
    @Environment(\.event) var event
    
    var body: some View {
        ScheduleCardBackground(color: event.workshopsColor) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Group {
                        Text(workshop.name)
                            .lineLimit(1)
                        
                        if let instructorName = workshop.instructorName {
                            Text(instructorName)
                                .font(.caption)
                        }
                        
                        Text(workshop.location)
                            .font(.caption)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WorkshopsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            
            WorkshopsView(
                store: .init(
                    initialState: .init(selectedDate: Event.testData.startDate),
                    reducer: WorkshopsFeature()
                )
            )
            .environment(\.event, .testData)
        }
    }
}
