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

                                Text(number.description)


                                Text(number.phoneNumber)

                                Spacer()
                                Button {

                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }

                            }
                            .textFieldStyle(.roundedBorder)
                        })


                        VStack {
                            TextField("Description", text: viewStore.binding(\.$contactNumberDescriptionText))
                            TextField("Phone Number", text: viewStore.binding(\.$contactNumberText))

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


                        Picker("Time Zone", selection: viewStore.binding(\.$timeZone), content: {
                            ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { tz in
                                if let timeZone = TimeZone(identifier: tz) {
                                    Text(timeZone.identifier)
                                }
                            }
                        })
                    }

                    Spacer()
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
                    initialState: .init(event: .testData, contactNumbers: .init(), contactNumberText: "", contactNumberDescriptionText: "", addressText: "", timeZone: ""),
                    reducer: eventDataReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
