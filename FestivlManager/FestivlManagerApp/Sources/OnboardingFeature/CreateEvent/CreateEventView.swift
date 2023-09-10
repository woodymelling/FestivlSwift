//
//  CreateEventView.swift
//
//
//  Created by Woodrow Melling on 8/7/23.
//

import SwiftUI
import PhotosUI
import SharedResources
import TimeZonePicker
import ComposableArchitecture
import Components

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

