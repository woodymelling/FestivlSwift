import XCTest
@testable import FestivlManagerApp
import ComposableArchitecture
import FestivlDependencies

let testSession = Session(user: .init(id: .init("id"), email: "bob@festivl.com"))

@MainActor
final class FestivlManagerAppTests: XCTestCase {
    func testLoginLogout() async throws {
        let store = TestStore(initialState: FestivlManagerDomain.State()) {
            FestivlManagerDomain()
        } withDependencies: {
            $0.authenticationClient.session = {
                [testSession, nil]
                    .publisher
                    .eraseToAnyPublisher()
            }
        }
        
        await store.send(.task)
        
        await store.receive(.dataUpdate(.session(testSession))) {
            $0.session = testSession
            $0.loggedInState = LoggedInDomain.State()
        }
        
        await store.receive(.dataUpdate(.session(nil))) {
            $0.loggedInState = nil
            $0.session = nil
        }
    }
}
