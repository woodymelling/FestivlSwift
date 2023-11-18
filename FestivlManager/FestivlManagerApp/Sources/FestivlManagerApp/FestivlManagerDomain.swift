import Foundation
import ComposableArchitecture
import Models
import FestivlDependencies
import Utilities
import OnboardingFeature

@Reducer
public struct FestivlManagerDomain {
    
    public init() {}
    
    public struct State: Equatable {
        public init() {}

        var home: HomeDomain.State = .init()
        @PresentationState var onboarding: OnboardingDomain.State?

        var session: Session?
    }
    
    public enum Action: Equatable {
        case task
        case dataUpdate(DataUpdate)
        
        case onboarding(PresentationAction<OnboardingDomain.Action>)
        case home(HomeDomain.Action)

        public enum DataUpdate: Equatable {
            case session(Session?)
        }
    }
    
    @Dependency(\.sessionClient.publisher) var sessionPublisher

    public var body: some ReducerOf<Self> {
        CombineReducers {

            Reduce { state, action in
                switch action {
                case .task:
                    /**
                     This runs at application start, which is before firebase can provide the app
                     with the already logged in user.

                     We have to drop the initial nil value provided so the app doesn't pop
                     the onboarding screen thinking we're in a logged out state

                     This is validated inFestivlManagerAppTests.testLoginLogout
                     */
                    return .observe(sessionPublisher().dropFirst()) { .dataUpdate(.session($0))
                    }

                case let .dataUpdate(dataType):
                    switch dataType {
                    case let .session(session):
                        state.session = session

                        if session == nil {
                            state.onboarding = OnboardingDomain.State()
                        }
                    }

                    return .none

                case .onboarding, .home:
                    return .none
                }
            }
            .ifLet(\.$onboarding, action: \.onboarding) {
                OnboardingDomain()
            }

            ReducerReader { state, _ in
                Scope(state: \.home, action: \.home) {
                    HomeDomain()
                        .dependency(\.session, state.session)
                }
            }
        }
        ._printChanges(
            .customDump { Logger.applicationRoot.debug("\($0)") }
        )
    }
}

import OSLog
extension Logger {
    static let applicationRoot = Logger(
        subsystem: "FestivlManager",
        category: "Application Root"
    )
}

extension _ReducerPrinter {
    static func osLog(
        to: Logger,
        level: OSLogType = .default
    ) -> Self {
        .customDump { Logger.applicationRoot.log(level: level, "\($0)") }
    }
}

public struct HomeDomain: Reducer {
    public init() {}

    public struct State: Equatable {
        public init() {}
    }

    public enum Action: Equatable {
        case task
        case didTapLogout
    }

    @Dependency(\.sessionClient.signOut) var signOut

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .none

            case .didTapLogout:
                return .run { send in
                    try? await self.signOut()
                }
            }
        }
    }
}

import SwiftUI

struct HomeView: View {
    var store: StoreOf<HomeDomain>

    var body: some View {
        Button("Logout") {
            store.send(.didTapLogout)
        }
        .buttonStyle(.bordered)
    }
}
