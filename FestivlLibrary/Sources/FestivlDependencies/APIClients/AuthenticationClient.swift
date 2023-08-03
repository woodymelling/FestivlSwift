//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/24/23.
//

import Foundation
import Models
import XCTestDynamicOverlay

public struct AuthenticationClient {
    public init(
        session: @escaping () -> AnyPublisher<Session?, Never>,
        signIn: @escaping (SignInUpData) async throws -> Void,
        signUp: @escaping (SignInUpData) async throws -> Void,
        signOut: @escaping () async throws -> Void
    ) {
        self.session = session
        self.signIn = signIn
        self.signUp = signUp
        self.signOut = signOut
    }
    
    public var session: () -> AnyPublisher<Session?, Never>
    
    /// Sign In a user. Throws FestivlError.SignInError
    public var signIn: (SignInUpData) async throws -> Void
    
    /// Sign out a user. Throws FestivlError.SignOutError
    public var signUp: (SignInUpData) async throws -> Void
    public var signOut: () async throws -> Void
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

extension AuthenticationClient: TestDependencyKey {
    public static var testValue = AuthenticationClient(
        session: unimplemented("AuthenticationClient.sessionPublisher"),
        signIn: unimplemented("AuthenticationClient.signIn"),
        signUp: unimplemented("AuthenticationClient.signUp"),
        signOut: unimplemented("AuthenticationClient.signOut")
    )
    
    public static var previewValue: AuthenticationClient = signedIn
    
    public static var signedIn = AuthenticationClient(
        session: { signedInPreviewAuthStore.publisher.eraseToAnyPublisher() },
        signIn: signedInPreviewAuthStore.signIn(_:),
        signUp: signedInPreviewAuthStore.signUp(_:),
        signOut: signedInPreviewAuthStore.signOut
    )
    
    public static var signedOut = AuthenticationClient(
        session: { signedOutPreviewAuthStore.publisher.eraseToAnyPublisher() },
        signIn: signedOutPreviewAuthStore.signIn(_:),
        signUp: signedOutPreviewAuthStore.signUp(_:),
        signOut: signedOutPreviewAuthStore.signOut
    )
}

public extension DependencyValues {
    var authenticationClient: AuthenticationClient {
        get { self[AuthenticationClient.self] }
        set { self[AuthenticationClient.self] = newValue }
    }
}

var signedOutPreviewAuthStore = InMemoryAuthenticationStore(startingSession: nil)
var signedInPreviewAuthStore = InMemoryAuthenticationStore(startingSession: .init(user: .init(id: "", email: "email@festivl.live")))

class InMemoryAuthenticationStore {
    init(startingSession: Session?) {
        self.publisher = .init(nil)
    }
    
    var publisher: CurrentValueSubject<Session?, Never>
    
    func signIn(_ signInData: SignInUpData) throws {
        publisher.send(.init(user: .init(id: "", email: signInData.email)))
    }
    
    func signUp(_ signUpData: SignInUpData) throws {
        publisher.send(.init(user: .init(id: "", email: signUpData.email)))
    }
    
    func signOut() {
        publisher.send(nil)
    }
    
}
