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
                                
                                AsyncImage(url: imageURL)
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
                    initialState: .init(event: .testData),
                    reducer: eventDataReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
