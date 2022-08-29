//
//  SiteMapView.swift
//
//
//  Created by Woody on 4/22/2022.
//

import SwiftUI
import ComposableArchitecture
import MacOSComponents


public struct EventDataView: View {
    let store: Store<EventDataState, EventDataAction>

    public init(store: Store<EventDataState, EventDataAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                Form {

                    Section("Site Map") {

                        if let imageURL = viewStore.event.siteMapImageURL {
                            ZStack {
                                AsyncImage(
                                    url: imageURL
//                                    content: { image in
//
//                                        image
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 200, height: 200)
//                                    },
//                                    placeholder: { }
                                )

                                Button(action: {
                                    viewStore.send(.didRemoveSiteMapImage)
                                }, label: {
                                    Label("Remove Site Map", systemImage: "trash")
                                })
                            }
                        }
                        Button(action: {
                            NSOpenPanel.openImage(completion: {
                                switch $0 {
                                case .success(let image):
                                    viewStore.send(.didSelectSiteMapImage(image))
                                case .failure:
                                    return
                                }

                            })
                        }, label: {
                            Text("Select Site Map")

                        })
                        .buttonStyle(.borderedProminent)
                    }

                    Divider()

                    Section(header: Text("Contact Numbers").font(.headline)) {

                        ForEach(viewStore.contactNumbers, content: { number in
                            HStack {
                                VStack(alignment: .leading) {

                                    HStack {

                                        Text(number.title)

                                        Text(number.phoneNumber)
                                    }
                                    Text(number.description)
                                }
                                Button {
                                    viewStore.send(.didTapDeleteContactNumber(number.id))
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                            .textFieldStyle(.roundedBorder)
                        })

                        VStack {
                            TextField("Title", text: viewStore.binding(\.$contactNumberTitleText))
                            TextField("Phone Number", text: viewStore.binding(\.$contactNumberText))
                            TextField("Description", text: viewStore.binding(\.$contactNumberDescriptionText))
                        }

                        Button("Save", action: {
                            viewStore.send(.didTapSaveContactNumber)
                        })
                    }

                    Divider()

                    Section(header: Text("Location").font(.headline)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Address")
                                TextEditor(text: viewStore.binding(\.$address))
                                    .frame(height: 100)
                            }
                        }

                        VStack(alignment: .leading) {
                            TextField("Latitude", text: viewStore.binding(\.$latitude))
                            TextField("Longitude", text: viewStore.binding(\.$longitude))
                        }

                        Picker("Time Zone", selection: viewStore.binding(\.$timeZone), content: {
                            ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { tz in
                                if let timeZone = TimeZone(identifier: tz) {
                                    Text(timeZone.identifier)
                                }
                            }
                        })
                    }

                    Spacer()
                    
                    Toggle(isOn: viewStore.binding(\.$isTestEvent), label: {
                        Text("Is Test Event")
                    })
                    
                    Button("Save all data") {
                        viewStore.send(.didTapSaveData)
                    }

                }
            }


        }
    }
}

struct EventDataView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            EventDataView(
                store: .init(
                    initialState: .init(
                        event: .testData,
                        contactNumbers: .init(),
                        contactNumberText: "",
                        contactNumberDescriptionText: "",
                        contactNumberTitleText: "",
                        addressText: "",
                        latitudeText: "",
                        longitudeText: "",
                        timeZone: "",
                        isTestEvent: false
                    ),
                    reducer: eventDataReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
