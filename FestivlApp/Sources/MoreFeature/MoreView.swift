//
//  MoreView.swift
//
//
//  Created by Woody on 4/22/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import NotificationsFeature

public struct MoreView: View {
    let store: StoreOf<MoreFeature>

    public init(store: StoreOf<MoreFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    Group { // Added for some weird compiler type-checking issue
                        NavigationLink {
                            NotificationsView(
                                store: store.scope(
                                    state: \.notificationsState,
                                    action: MoreFeature.Action.notificationsAction
                                )
                            )
                        } label: {
                            Label("Notifications", systemImage: "bell.badge.fill")
                                .labelStyle(ColorfulIconLabelStyle(color: .red))
                        }
                        
                        
                        if let imageURL = viewStore.event.siteMapImageURL {
                            NavigationLink(destination: {
                                SiteMapView(imageURL: imageURL)
                                
                            }, label: {
                                Label("Site Map", systemImage: "map.fill")
                                    .labelStyle(ColorfulIconLabelStyle(color: .purple))
                            })
                        }
                        
                        if let contactNumbers = viewStore.event.contactNumbers, !contactNumbers.isEmpty {
                            NavigationLink(destination: {
                                ContactInfoView(contactNumbers: contactNumbers)
                            }, label: {
                                Label("Contact Information", systemImage: "phone.fill")
                                    .labelStyle(ColorfulIconLabelStyle(color: .blue))
                            })
                        }
                        if let address = viewStore.event.address, !address.isEmpty {
                            NavigationLink(destination: {
                                AddressView(
                                    address: address,
                                    latitude: viewStore.event.latitude ?? "",
                                    longitude: viewStore.event.longitude ?? ""
                                )
                            }, label: {
                                Label("Address", systemImage: "mappin")
                                    .labelStyle(ColorfulIconLabelStyle(color: .green))
                            })
                        }
                    }

                    
                    if !viewStore.isEventSpecificApplication {
                        Section {
                            Button("Exit \(viewStore.event.name)", action: {
                                viewStore.send(.didExitEvent, animation: .default)
                            })
                        }
                    }
                    
                }
                .listStyle(.insetGrouped)
                .navigationTitle("More")
            }
        }
    }
}

struct ColorfulIconLabelStyle: LabelStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            configuration.icon
                .font(.system(size: 17))
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 7).frame(width: 28, height: 28).foregroundColor(color))
        }
    }
}

extension LabelStyle {
    static func colorfulIcon(color: Color) -> ColorfulIconLabelStyle {
        ColorfulIconLabelStyle(color: color)
    }
}

fileprivate struct SFSymbolKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            MoreView(
                store: .init(
                    initialState: .init(
                        event: .testData,
                        favoriteArtists: .init(),
                        schedule: .init(),
                        artists: Artist.testValues.asIdentifedArray,
                        stages: Stage.testValues.asIdentifedArray,
                        isTestMode: true,
                        notificationsEnabled: false,
                        notificationTimeBeforeSet: 5,
                        showingNavigateToSettingsAlert: false,
                        isEventSpecificApplication: true
                    ),
                    reducer: MoreFeature()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
