//
//  NotificationsView.swift
//
//
//  Created by Woody on 4/23/2022.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct NotificationsView: View {
    let store: StoreOf<NotificationsFeature>

    public init(store: StoreOf<NotificationsFeature>) {
        self.store = store
    }

    var notificationTimes: [Int] {
        return Array(1...12).map { $0 * 5 }
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Toggle(
                    "Notify me for favorite artists",
                    isOn: viewStore.$notificationsEnabled
                )

                if viewStore.notificationsEnabled {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Time before set:")
                        Picker(
                            "Time before set",
                            selection: viewStore.$notificationTimeBeforeSet,
                            content: {
                                ForEach(notificationTimes, id: \.self) { time in
                                    Text("\(time) minutes")
                                        .tag(time)
                                }
                            }
                        )
                        .pickerStyle(.wheel)
                    }
                }


                if viewStore.currentEnvironment == .test {
                    Section("Testing") {
                        Button("Send notifications now", action: {
                            viewStore.send(.didTapSendNotificationsButton)
                        })
                    }
                }
            }
            .task { await viewStore.send(.task).finish() }
            .navigationTitle("Notifications")
            .alert(
                "Enable notifications in Settings to receive alerts for artists",
                isPresented: viewStore.$showingNavigateToSettingsAlert,
                actions: {
                    Button("Settings") {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                            UIApplication.shared.open(appSettings)
                        }
                    }

                    Button("Cancel", role: .cancel) { }
                }
            )
            
        }
    }
}

//struct NotificationsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
//            NavigationView {
//                NotificationsView(
//                    store: .init(
//                        initialState: .init(
//                            favoriteArtists: .init(),
//                            schedule: .init(),
//                            artists: Artist.testValues.asIdentifedArray,
//                            stages: Stage.testValues.asIdentifedArray,
//                            isTestMode: true,
//                            notificationsEnabled: false,
//                            notificationTimeBeforeSet: 15,
//                            showingNavigateToSettingsAlert: false
//                        ),
//                        reducer: NotificationsFeature()
//                    )
//                )
//            }
//            .preferredColorScheme($0)
//        }
//    }
//}
