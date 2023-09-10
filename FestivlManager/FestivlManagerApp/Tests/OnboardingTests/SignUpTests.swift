import XCTest
@testable import OnboardingFeature
import ComposableArchitecture
import FestivlDependencies


let testEmail = "bob@festivl.live"
let testPassword = "qwer1234"
var filledInState: SignUpDomain.State {
    SignUpDomain.State(email: testEmail, password: testPassword)
}

@MainActor
final class SignUpTests: XCTestCase {
    
    func testSignUpHappyPath() async {
        
        let store = TestStore(initialState: SignUpDomain.State()) {
            SignUpDomain()
        } withDependencies: {
            $0.sessionClient.signUp = {
                XCTAssert($0.email == testEmail)
                XCTAssert($0.password == testPassword)

                return "12345"
            }
        }
        
        await store.send(.binding(.set(\.$email, testEmail))) {
            $0.email = testEmail
        }
        
        await store.send(.binding(.set(\.$password, testPassword))) {
            $0.password = testPassword
        }
        
        await store.send(.form(.submittedForm)) {
            $0.isCreatingAccount = true
        }
        
        await store.receive(.succesfullyCreatedAccount("12345")) {
            $0.isCreatingAccount = false
        }
    }
    
    // MARK: API Errors
    func testSignUpEmailErrorMessage() async {
        
        let store = TestStore(initialState: filledInState) {
            SignUpDomain()
        } withDependencies: {
            $0.sessionClient.signUp = { _ in
                throw FestivlError.SignUpError.invalidEmail
            }
        }
        
        await store.send(.form(.submittedForm)) {
            $0.isCreatingAccount = true
        }
        
        await store.receive(.failedToCreateAccount(.invalidEmail)) {
            $0.isCreatingAccount = false
            $0.formState.validationErrors[.email] = ["Invalid email."]
        }
    }
    
    func testSignUpPasswordErrorMessage() async {
        let store = TestStore(initialState: filledInState) {
            SignUpDomain()
        } withDependencies: {
            $0.sessionClient.signUp = { _ in
                throw FestivlError.SignUpError.weakPassword
            }
        }
        
        await store.send(.form(.submittedForm)) {
            $0.isCreatingAccount = true
        }
        
        await store.receive(.failedToCreateAccount(.weakPassword)) {
            $0.isCreatingAccount = false
            $0.formState.validationErrors[.password] = ["Weak password."]
        }
    }
    
    func testSignUpOtherErrorMessage() async {
        let store = TestStore(initialState: filledInState) {
            SignUpDomain()
        } withDependencies: {
            $0.sessionClient.signUp = { _ in
                throw FestivlError.SignUpError.other
            }
        }
        
        await store.send(.form(.submittedForm)) {
            $0.isCreatingAccount = true
        }
        
        await store.receive(.failedToCreateAccount(.other)) {
            $0.isCreatingAccount = false
            $0.submitError = "Failed to create account."
        }
    }
}
