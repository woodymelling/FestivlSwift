//
// NotificationsDomain.swift
//
//
//  Created by Woody on 4/23/2022.
//

import ComposableArchitecture
import Models
import UserNotifications
import FestivlDependencies

public struct NotificationsFeature: Reducer {
    
    public init() {}

    @Dependency(\.userFavoritesClient) var userFavoritesClient
    @Dependency(\.userNotificationCenter) var notificationCenter
    @Dependency(\.currentEnvironment) var currentEnvironment
    
    
    public struct State: Equatable {
        public init() {}
        
        @BindingState public var notificationsEnabled: Bool = false
        @BindingState public var notificationTimeBeforeSet: Int = 0

        // TODO: Change to PresentationState
        @BindingState public var showingNavigateToSettingsAlert: Bool = false
     
        var currentEnvironment: FestivlEnvironment = .live
    }
    
    public enum Action: BindableAction {
        case binding(_ action: BindingAction<State>)
        case notifictationsPermitted
        case notificationsDenied
        
        case didTapSendNotificationsButton
        
        case task
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .task:
                
                print("NOTIFS Task")
                userFavoritesClient.registerNotificationCategories()
                state.currentEnvironment = currentEnvironment
                
                
                state.notificationsEnabled = userFavoritesClient.notificationsEnabled()
                state.notificationTimeBeforeSet = userFavoritesClient.beforeSetNotificationTime()
                
            case .binding(\.$notificationsEnabled):
                if state.notificationsEnabled {
                    return .run { send in
                        do {
                            if try await notificationCenter().requestAuthorization(options: [.alert, .sound]) {
                                await send(.notifictationsPermitted)
                            } else {
                                await send(.notificationsDenied)
                            }
                        } catch {
                            await send(.notificationsDenied)
                        }
                    }
                } else {
                    userFavoritesClient.updateNotificationSettings(false, state.notificationTimeBeforeSet)
                }

            case .binding(\.$notificationTimeBeforeSet):
                userFavoritesClient.updateNotificationSettings(state.notificationsEnabled, state.notificationTimeBeforeSet)

            case .binding:
                return .none


            case .notificationsDenied:
                state.showingNavigateToSettingsAlert = true
                
                userFavoritesClient.updateNotificationSettings(false, state.notificationTimeBeforeSet)

                return .none

            case .notifictationsPermitted:
                userFavoritesClient.updateNotificationSettings(true, state.notificationTimeBeforeSet)
                
            case .didTapSendNotificationsButton:
                userFavoritesClient.sendNotificationsNow()
            }
            
            return .none
        }
    }
}
