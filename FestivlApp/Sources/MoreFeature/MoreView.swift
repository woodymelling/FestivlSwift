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
            LoadingView(viewStore.eventData) { eventData in
                List {
                    Section {
                        MoreButton(
                            "Workshops",
                            image: Image("workshops", bundle: .module),
                            color: workshopsColor
                        ) {
                            viewStore.send(.didTapWorkshops)
                        }
                    }
                    
                    Section {
                        if eventData.event.siteMapImageURL != nil {
                            MoreButton("Site Map", systemName: "map.fill", color: .customBlue) {
                                viewStore.send(.didTapSiteMap)
                            }
                        }
                        
                        if !eventData.event.address.isNilOrEmpty {
                            MoreButton("Address", systemName: "mappin", color: .customPurple) {
                                viewStore.send(.didTapAddress)
                            }
                        }
                    }
                    
                    Section {
                        MoreButton("Notifications", systemName: "bell.badge.fill", color: .customRed) {
                            viewStore.send(.didTapNotifications)
                        }
                    }
                    
                    Section {
                        if !eventData.event.contactNumbers.isNilOrEmpty {
                            MoreButton("Emergency Contact", systemName: "phone.fill", color: .customOrange) {
                                viewStore.send(.didTapContactInfo)
                            }
                        }
                    }
                    
                    Section {
                        if !viewStore.isEventSpecificApplication {
                            Button {
                                viewStore.send(.didExitEvent, animation: .default)
                            } label: {
                                Text("Exit \(viewStore.eventData?.event.name ?? "")")
                            }
                        }
                    }
                    
                    if viewStore.isShowingKeyInput {
                        Section {
                            TextField("Internal Preview Key", text: viewStore.$keyInputText)
                                .textInputAutocapitalization(.none)
                            Button("Unlock Internal Preview") {
                                viewStore.send(.didTapUnlockInternalPreview)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("More")
                
            }
            .onTapGesture(count: 7) {
                viewStore.send(.didTap7Times)
            }
            .task { await viewStore.send(.task).finish() }
            .navigationDestination(
                store: destinationStore,
                state: /MoreFeature.Destination.State.workshops,
                action: MoreFeature.Destination.Action.workshops,
                destination: WorkshopsView.init
            )
            .navigationDestination(
                store: destinationStore,
                state: /MoreFeature.Destination.State.siteMap,
                action: MoreFeature.Destination.Action.siteMap,
                destination: SiteMapView.init
            )
            .navigationDestination(
                store: destinationStore,
                state: /MoreFeature.Destination.State.address,
                action: MoreFeature.Destination.Action.address,
                destination: AddressView.init
            )
            .navigationDestination(
                store: destinationStore,
                state: /MoreFeature.Destination.State.notifications,
                action: MoreFeature.Destination.Action.notifications,
                destination: NotificationsView.init
            )
            .navigationDestination(
                store: destinationStore,
                state: /MoreFeature.Destination.State.contactInfo,
                action: MoreFeature.Destination.Action.contactInfo,
                destination: ContactInfoView.init
            )
        }
    }
    
    var destinationStore: PresentationStoreOf<MoreFeature.Destination> {
        self.store.scope(
            state: \.$destination,
            action: MoreFeature.Action.destination
        )
    }
}

typealias PresentationStoreOf<R: Reducer> = Store<PresentationState<R.State>, PresentationAction<R.Action>>

struct LoadingView<T, Content: View>: View {
    let value: T?
    let content: (T) -> Content
    
    init(_ value: T?, content: @escaping (T) -> Content) {
        self.value = value
        self.content = content
    }
    
    var body: some View {
        if let value {
            content(value)
        } else {
            ProgressView()
        }
    }
}

internal struct ColorfulIconLabelStyle: LabelStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
                .foregroundStyle(Color.label)
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

struct MoreButton: View {
    var title: () -> Text
    var image: () -> Image
    var color: Color
    var action: () -> Void
    
    init(_ title: LocalizedStringKey, systemName: String, color: Color, action: @escaping () -> Void) {
        self.title = { Text(title) }
        self.image = { Image(systemName: systemName) }
        self.color = color
        self.action = action
    }
    
    init(_ title: LocalizedStringKey, image: Image, color: Color, action: @escaping () -> Void) {
        self.title = { Text(title) }
        self.image = { image.resizable() }
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Label(title: title, icon: image)
                .labelStyle(ColorfulIconLabelStyle(color: color))
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MoreView(
                store: .init(
                    initialState: .init(),
                    reducer: MoreFeature.init
                )
            )
        }
    }
}
