//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/22/23.
//

import Foundation
import ComposableArchitecture
import Utilities
import Models
import FestivlDependencies
import Combine

public struct WorkshopsFeature: Reducer {
    @Dependency(\.workshopsClient) var workshopsClient
    @Dependency(\.eventClient) var eventClient
    @Dependency(\.eventID) var eventID
    @Dependency(\.date) var date
    
    public init() {}
    
    public struct State: Equatable {
        @BindingState var selectedDate: CalendarDate
        @BindingState var selectedWorkshop: Workshop?
        
        var workshops: [CalendarDate : IdentifiedArrayOf<Workshop>] = [:]
        
        
        public init(selectedDate: CalendarDate? = nil) {
            @Dependency(\.date) var date
            self.selectedDate = selectedDate ?? CalendarDate(date: date())
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case task
        case binding(_ action: BindingAction<State>)
        
        case loadedData(Event, [CalendarDate : IdentifiedArrayOf<Workshop>])
        
        case didSelectDay(CalendarDate)
        
        case didTapWorkshop(Workshop)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
            case .task:
                return .run { send in
                    for try await (event, workshops) in Publishers.CombineLatest(
                        eventClient.getEvent(),
                        workshopsClient.fetchWorkshops(eventID)
                    ).values {
                        await send(.loadedData(event, workshops.sortedByDay))
                    }
                }
                
            case let .loadedData(event, workshops):
                state.workshops = workshops
                state.selectedDate = event.dateForCalendarAtLaunch(
                    selectedDate: state.selectedDate
                )
                
                return .none
                
            case let .didSelectDay(day):
                state.selectedDate = day
                
                return .none
                
            case let .didTapWorkshop(workshop):
                state.selectedWorkshop = workshop
                
                return .none
            }
        }
    }
}

extension IdentifiedArrayOf<Workshop> {
    var sortedByDay: [CalendarDate : IdentifiedArrayOf<Workshop>] {
        
        var dict: [CalendarDate: IdentifiedArrayOf<Workshop>] = [:]
        
        
        self.forEach {
            let date = CalendarDate(date: $0.startTime)
            
            if dict[date] != nil {
                
                dict[date]?.append($0)
            } else {
                dict[date] = [$0]
            }
        }
        
        return dict
    }
}
