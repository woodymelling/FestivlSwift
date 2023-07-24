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


extension Workshop {
    var wickedWoodsWorkshopWrapper: TimelineWrapper<Workshop> {
        
        let sortOrder: Int
        switch self.location {
        case "Relaxation Ridge": sortOrder = 0
        case "Ursus": sortOrder = 1
        case "Art Gallery": sortOrder = 2
        default: sortOrder = 3
        }
        
        return TimelineWrapper(
            groupWidth: sortOrder..<sortOrder,
            item: self
        )
    }
}

public struct WorkshopsView: View {
    public init(store: StoreOf<WorkshopsFeature>) {
        self.store = store
    }
    
    let store: StoreOf<WorkshopsFeature>
    
    @Environment(\.event) var event
    
    
    struct ViewState: Equatable {
        var workshops:  IdentifiedArrayOf<Workshop>
        @BindingViewState var selectedDate: CalendarDate
        @BindingViewState var selectedWorkshop: Workshop?
        
        init(state: BindingViewStore<WorkshopsFeature.State>) {
            self.workshops = state.workshops[state.selectedDate] ?? []
            self._selectedDate = state.$selectedDate
            self._selectedWorkshop = state.$selectedWorkshop
        }
    }
    
    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ScrollViewReader { proxy in
                ScrollView {
                    SchedulePageView(viewStore.workshops.map { $0.wickedWoodsWorkshopWrapper }) { workshop in
                        WorkshopCard(workshop: workshop.item)
                            .onTapGesture {
                                viewStore.send(.didTapWorkshop(workshop.item))
                            }
                    }
                }
                .task {
                    proxy.scrollTo(ScheduleHourTag(hour: 12), anchor: .center)
                }
            }
            .task { await viewStore.send(.task).finish() }
            .toolbarDateSelector(selectedDate: viewStore.$selectedDate.animation())
            .environment(\.dayStartsAtNoon, false) //
            .environment(\.calendarSelectedDate, viewStore.selectedDate)
            .sheet(
                item: viewStore.$selectedWorkshop,
                content: WorkshopDetailsView.init
            )
        }
    }
}

extension Workshop: TimeRangeRepresentable {
    public var timeRange: Range<Date> {
        
        guard startTime < endTime else {
            return Date.now..<(Date.now + 1.seconds)
        }
        
        return startTime..<endTime
    }
}

struct WorkshopCard: View {
    var workshop: Workshop
    
    @Environment(\.event) var event
    
    var body: some View {
        ScheduleCardBackground(color: event.workshopsColor) {
            HStack(alignment: .center) {
                
                GeometryReader { geo in
                    VStack(alignment: .leading) {
                        Text(workshop.name)
                            .lineLimit(1)
                        
                        
                        Text(workshop.location)
                            .font(.caption2)
                        
                        if let instructorName = workshop.instructorName {
                            Text(instructorName)
                                .font(.caption2)
                        }
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
        
    }
}

struct WorkshopsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            
            WorkshopsView(
                store: StoreOf<WorkshopsFeature>(
                    initialState: .init(selectedDate: Event.previewData.startDate),
                    reducer: WorkshopsFeature.init
                )
            )
            .environment(\.event, .previewData)
        }
    }
}
