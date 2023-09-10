//
//  CreateEventDomain.swift
//  
//
//  Created by Woodrow Melling on 8/12/23.
//

import Foundation
import ComposableArchitecture
import ComposableArchitectureForms
import ComposablePhotosPicker

public struct CreateEventDomain: Reducer {
    public struct State: Equatable {
        public init() {
            @Dependency(\.date) var todaysDate
            @Dependency(\.timeZone) var currentTimeZone
            
            self.startDate = todaysDate()
            self.endDate = todaysDate().addingTimeInterval(1.days)
            self.timeZone = currentTimeZone

            self.dayStartsAtNoon = false
        }

        init(
            startDate: Date,
            endDate: Date,
            timeZone: TimeZone,
            dayStartsAtNoon: Bool
        ) {
            self.startDate = startDate
            self.endDate = endDate
            self.timeZone = timeZone
            self.dayStartsAtNoon = dayStartsAtNoon
        }

        @BindingState var startDate: Date
        @BindingState var endDate: Date
        @BindingState var timeZone: TimeZone
        
        @BindingState var dayStartsAtNoon: Bool

        @BindingState var eventImage: PhotosPickerDomain.State = .init()
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case photosPicker(PhotosPickerDomain.Action)

        case didTapCreateEvent
        case delegate(Delegate)

        public enum Delegate {
            case didFinishCreatingEvent
        }
    }

    @Dependency(\.calendar) var calendar

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .photosPicker(state: \.eventImage, action: /Action.photosPicker)

        Reduce { state, action in
            switch action {

            case .didTapCreateEvent:
                return .send(.delegate(.didFinishCreatingEvent))
                
            case .binding(\.$startDate):
                state.endDate = Calendar.current.date(byAdding: .day, value: 1, to: state.startDate) ?? state.endDate
                
                return .none
            case .binding, .photosPicker, .delegate:
                return .none
            }
        }

    }
}
