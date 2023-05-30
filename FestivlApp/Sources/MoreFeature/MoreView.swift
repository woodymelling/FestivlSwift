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
import WorkshopsFeature

extension Color {
    static var customPurple = Color(hex: "#401F34")
    static var customRed = Color(hex: "#A62428")
    static var customOrange = Color(hex: "#DE5F29")
    static var customBlue = Color(hex: "#143144")
}

public struct MoreView: View {
    let store: StoreOf<MoreFeature>
    
    public init(store: StoreOf<MoreFeature>) {
        self.store = store
    }
    
    @Environment(\.event.workshopsColor) var workshopsColor
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if let eventData = viewStore.eventData {
                    List {
                        Section {
                            NavigationLinkStore(
                                store.scope(state: \.$destination, action: MoreFeature.Action.destination),
                                state: /MoreFeature.Destination.State.workshops,
                                action: MoreFeature.Destination.Action.workshops,
                                onTap: { viewStore.send(.didTapWorkshops) },
                                destination: WorkshopsView.init,
                                label: {
                                    Label(title: {
                                        Text("Workshops")
                                    }, icon: {
                                        Image("workshops", bundle: .module)
                                            .resizable()
                                    })
                                    .labelStyle(ColorfulIconLabelStyle(color: workshopsColor))
                                }
                            )
                        }
                        
                        Section {
                            if eventData.event.siteMapImageURL != nil {
                                
                                NavigationLinkStore(
                                    store.scope(state: \.$destination, action: MoreFeature.Action.destination),
                                    state: /MoreFeature.Destination.State.siteMap,
                                    action: MoreFeature.Destination.Action.siteMap,
                                    onTap: { viewStore.send(.didTapSiteMap) },
                                    destination: {
                                        SiteMapView(store: $0)
                                    },
                                    label: {
                                        Label("Site Map", systemImage: "map.fill")
                                            .labelStyle(ColorfulIconLabelStyle(color: .customBlue))
                                    }
                                )
                            }

                            if !eventData.event.address.isNilOrEmpty {
                                NavigationLinkStore(
                                    store.scope(state: \.$destination, action: MoreFeature.Action.destination),
                                    state: /MoreFeature.Destination.State.address,
                                    action: MoreFeature.Destination.Action.address,
                                    onTap: { viewStore.send(.didTapAddress) },
                                    destination: { AddressView(store: $0) },
                                    label: {
                                        Label("Address", systemImage: "mappin")
                                            .labelStyle(ColorfulIconLabelStyle(color: .customPurple))
                                    }
                                )
                            }
                        }
                        
                        Section {
                            NavigationLinkStore(
                                store.scope(state: \.$destination, action: MoreFeature.Action.destination),
                                state: /MoreFeature.Destination.State.notifications,
                                action: MoreFeature.Destination.Action.notifications,
                                onTap: { viewStore.send(.didTapNotifications) },
                                destination: {
                                    NotificationsView(store: $0)
                                },
                                label: {
                                    Label("Notifications", systemImage: "bell.badge.fill")
                                        .labelStyle(ColorfulIconLabelStyle(color: .customRed))
                                }
                            )
                        }
                        
                        Section {
                            if !eventData.event.contactNumbers.isNilOrEmpty {
                                NavigationLinkStore(
                                    store.scope(state: \.$destination, action: MoreFeature.Action.destination),
                                    state: /MoreFeature.Destination.State.contactInfo,
                                    action: MoreFeature.Destination.Action.contactInfo,
                                    onTap: { viewStore.send(.didTapContactInfo) },
                                    destination: { ContactInfoView(store: $0) },
                                    label: {
                                        Label("Emergency Contact", systemImage: "phone.fill")
                                            .labelStyle(ColorfulIconLabelStyle(color: .customOrange))
                                    }
                                )
                            }
                        }

                        

                        if !viewStore.isEventSpecificApplication {
                            Section {
                                Button {
                                    viewStore.send(.didExitEvent, animation: .default)
                                } label: {
                                    Text("Exit \(viewStore.eventData?.event.name ?? "")")
                                }
                            }
                        }
                        
                        if viewStore.isShowingKeyInput {
                            Section {
                                TextField("Internal Preview Key", text: viewStore.binding(get: \.keyInputText, send: { .didUpdateKeyInput($0) } ))
                                    .textInputAutocapitalization(.none)
                                Button("Unlock Internal Preview") {
                                    viewStore.send(.didTapUnlockInternalPreview)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("More")
                } else {
                    ProgressView()
                }
            }
            .onTapGesture(count: 7) {
                viewStore.send(.didTap7Times)
            }
            .task { await viewStore.send(.task).finish() }
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
                .aspectRatio(contentMode: .fit)
                .font(.system(size: 17))
                .frame(square: 20)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                    .frame(square: 28)
                    .foregroundColor(color)
                )
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
        NavigationView {
            
            MoreView(
                store: .init(
                    initialState: .init(),
                    reducer: MoreFeature()
                )
            )
        }
    }
}
