import Foundation
import ComposableArchitecture
import Models
import FestivlDependencies
import Utilities

public struct FestivlManagerDomain: Reducer {
    
    public init() {}
    
    public struct State: Equatable {
        
        public init(loggedInState: LoggedInDomain.State? = nil, homePageState: HomePageDomain.State = .init()) {
            self.loggedInState = loggedInState
            self.homePageState = homePageState
        }
        
        @PresentationState var loggedInState: LoggedInDomain.State?
        var homePageState: HomePageDomain.State = .init()
        
        var session: Session?
    }
    
    public enum Action: Equatable {
        case task
        case dataUpdate(DataUpdate)
        
        case loggedIn(PresentationAction<LoggedInDomain.Action>)
        case homePage(HomePageDomain.Action)
        
        public enum DataUpdate: Equatable {
            case session(Session?)
        }
    }
    
    @Dependency(\.authenticationClient) var authenticationClient
        
    public var body: some ReducerOf<Self> {
        ReducerReader { state, _ in
            Reduce { state, action in
                switch action {
                case .task:
                    return .observe(authenticationClient.session()) { .dataUpdate(.session($0)) }
                    
                case let .dataUpdate(dataType):
                    switch dataType {
                    case let .session(session):
                        state.session = session
                        state.loggedInState = session.map { _ in .init() }
                    }
                    
                    return .none
                    
                case .loggedIn, .homePage:
                    return .none
                }
            }
            .ifLet(\.$loggedInState, action: /Action.loggedIn) {
                LoggedInDomain()
                    .dependency(\.session, state.session)
            }
        }
        
        Scope(state: \.homePageState, action: /Action.homePage) {
            HomePageDomain()
        }
    }
}
