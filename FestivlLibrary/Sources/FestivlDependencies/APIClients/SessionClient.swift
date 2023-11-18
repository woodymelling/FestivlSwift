//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/24/23.
//

import Foundation
import Models
import XCTestDynamicOverlay
import DependenciesMacros

@DependencyClient
public struct SessionClient {
    public var publisher: () -> AnyPublisher<Session?, Never> = { Empty().eraseToAnyPublisher() }

    /// Sign In a user. Throws FestivlError.SignInError
    public var signIn: (SignInUpData) async throws -> User.ID

    /// Sign out a user. Throws FestivlError.SignOutError
    public var signUp: (SignInUpData) async throws -> User.ID
    public var signOut: () async throws -> Void

    public var selectOrganization: (Organization.ID) async throws -> Void
    public var selectEvent: (Event.ID) async throws -> Void
}

extension FestivlError {
    public enum SignUpError: Error {
        /// The authentication service is disabled
        case operationNotAllowed
        
        /// The email address is already in use by another account.
        case emailAlreadyInUse
        
        /// The email address is badly formatted
        case invalidEmail
        
        /// The password must be 6 characters long or more.
        case weakPassword
        
        case other
    }
    
    public enum SignInError: Error {
        case operationNotAllowed, userDisabled, wrongPassword, invalidEmail
        case other
    }
    
    public enum SignOutError: Error {
        case keychainError
        case other
    }
}

extension SessionClient: TestDependencyKey {
    public static var testValue = Self()

    public static var previewValue: SessionClient = signedIn
    
    public static var signedIn = SessionClient(
        publisher: { signedInPreviewAuthStore.publisher.eraseToAnyPublisher() },
        signIn: signedInPreviewAuthStore.signIn(_:),
        signUp: signedInPreviewAuthStore.signUp(_:),
        signOut: signedInPreviewAuthStore.signOut,
        selectOrganization: signedInPreviewAuthStore.selectOrganization(_:),
        selectEvent: signedInPreviewAuthStore.selectEvent(_:)
    )
    
    public static var signedOut = SessionClient(
        publisher: { signedOutPreviewAuthStore.publisher.eraseToAnyPublisher() },
        signIn: signedOutPreviewAuthStore.signIn(_:),
        signUp: signedOutPreviewAuthStore.signUp(_:),
        signOut: signedOutPreviewAuthStore.signOut,
        selectOrganization: signedOutPreviewAuthStore.selectOrganization(_:),
        selectEvent: signedOutPreviewAuthStore.selectEvent(_:)
    )
}

public extension DependencyValues {
    var sessionClient: SessionClient {
        get { self[SessionClient.self] }
        set { self[SessionClient.self] = newValue }
    }
}

var signedOutPreviewAuthStore = InMemoryAuthenticationStore(session: nil)
var signedInPreviewAuthStore = InMemoryAuthenticationStore(
    session: Session(
        user: .init(id: "", email: "email@festivl.live"),
        organization: nil,
        event: nil
    )
)

class InMemoryAuthenticationStore {
    init(session: Session?) {
        self.publisher = .init(session)
    }
    
    var publisher: CurrentValueSubject<Session?, Never>
    
    func signIn(_ signInData: SignInUpData) throws -> User.ID {
        publisher.send(
            .init(
                user: .init(id: "12345", email: signInData.email),
                organization: nil,
                event: nil
            )
        )

        return "12345"
    }
    
    func signUp(_ signUpData: SignInUpData) throws -> User.ID {
        publisher.send(
            .init(
                user: .init(id: "12345", email: signUpData.email),
                organization: nil,
                event: nil
            )
        )
        return "12345"
    }
    
    func signOut() {
        publisher.send(nil)
    }

    func selectOrganization(_ organizationID: Organization.ID) {
        publisher.value?.selectedOrganization = organizationID
    }

    func selectEvent(_ organizationID: Event.ID) {
        publisher.value?.selectedEvent = organizationID
    }

}
