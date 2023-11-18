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
import SwiftUI
import PhotosUI
import SharedResources
import TimeZonePicker
import Components

@Reducer
public struct CreateEventDomain {
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
                state.endDate = state.startDate.addingTimeInterval(1.days)
                return .none
                
            case .binding, .photosPicker, .delegate:
                return .none
            }
        }
    }
}


struct CreateEventView: View {

    let store: StoreOf<CreateEventDomain>

    init(store: StoreOf<CreateEventDomain>) {
        self.store = store
    }

    @Environment(\.colorScheme) var colorScheme
    var logoColor: Color {
        switch colorScheme {
        case .light: Color.accentColor
        case .dark: Color.label
        @unknown default: Color.label
        }
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    DatePicker(
                        "First Day",
                        selection: viewStore.$startDate,
                        in: Date.now...,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "Last Day",
                        selection: viewStore.$endDate,
                        in: viewStore.startDate...,
                        displayedComponents: .date
                    )

                    TimeZonePicker(selectedTimeZone: viewStore.$timeZone)
                }

                Section {
                    Toggle("Schedule Starts at Noon", isOn: viewStore.$dayStartsAtNoon)
                } footer: {
                    Text(
                    """
                    Enable this if your performances go past midnight; a "day" will start at noon, and end at noon 24 hours later.
                    """
                    )
                }

                Section {
                    PhotosPicker("Upload Your Logo", selection: viewStore.$eventImage.pickerItem)
                } footer: {
                    HStack(spacing: 15) {

                        Group {
                            if let image = viewStore.eventImage.image {
                                ContentAwareTemplateImage(image: image.resizable())
                            } else {
                                FestivlAssets
                                    .logo
                                    .resizable()
                            }
                        }
                        .frame(square: 100)
                        .foregroundStyle(self.logoColor)
                        .padding(.top, 5)

                        IconImageCriteriaView(image: viewStore.eventImage.image)
                            .truncationMode(.tail)
                            .lineLimit(1)




                        Spacer()
                    }
                }

                Section { } footer: {
                    VStack {
                        Text("You can change any of this information later.")

                        Button {
                            viewStore.send(.didTapCreateEvent)
                        } label: {
                            Text("Get Started!")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Create Your Event")
        }
    }
}

#Preview {
    Text("Blah")
        .sheet(isPresented: .constant(true), content: {
            NavigationStack {

                CreateEventView(store: Store(initialState: CreateEventDomain.State()) {
                    CreateEventDomain()
                        ._printChanges()
                })
            }
        })
}

