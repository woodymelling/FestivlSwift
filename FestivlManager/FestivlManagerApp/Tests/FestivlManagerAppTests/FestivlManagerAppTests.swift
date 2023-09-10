import XCTest
@testable import FestivlManagerApp
import ComposableArchitecture
import FestivlDependencies

let testSession = Session(user: .init(id: .init("id"), email: "bob@festivl.com"))

@MainActor
final class FestivlManagerAppTests: XCTestCase {
    func testLoginLogout() async throws {

        let sessionPublisher = CurrentValueSubject<Session?, Never>(nil)

        let store = TestStore(initialState: FestivlManagerDomain.State()) {
            FestivlManagerDomain()
        } withDependencies: {
            $0.authenticationClient.session = {
                sessionPublisher.eraseToAnyPublisher()
            }
        }
        
        await store.send(.task)

        sessionPublisher.send(testSession)

        await store.receive(.dataUpdate(.session(testSession))) {
            $0.session = testSession
        }

        sessionPublisher.send(nil)

        await store.receive(.dataUpdate(.session(nil))) {
            $0.session = nil
            $0.onboarding = .init()
        }

        sessionPublisher.send(completion: .finished)
    }
}
