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
    let store: Store<MoreState, MoreAction>

    public init(store: Store<MoreState, MoreAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    NavigationLink {
                        NotificationsView(
                            store: store.scope(
                                state: \.notificationsState,
                                action: MoreAction.notificationsAction
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
                }
                .listStyle(.insetGrouped)
                .navigationTitle("More")
            }
        }
    }
}

struct ColoredIconView: View {

    let imageName: String
    let foregroundColor: Color
    let backgroundColor: Color
    @State private var frameSize: CGSize = CGSize(width: 30, height: 30)
    @State private var cornerRadius: CGFloat = 5

    var body: some View {
        Image(systemName: imageName)
            .overlay(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: SFSymbolKey.self, value: max(proxy.size.width, proxy.size.height))
                }
            )
            .onPreferenceChange(SFSymbolKey.self) {
                let size = $0 * 1.05
                frameSize = CGSize(width:size, height: size)
                cornerRadius = $0 / 6.4
            }
            .frame(width: frameSize.width, height: frameSize.height)
            .foregroundColor(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
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
                        showingNavigateToSettingsAlert: false
                    ),
                    reducer: moreReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
