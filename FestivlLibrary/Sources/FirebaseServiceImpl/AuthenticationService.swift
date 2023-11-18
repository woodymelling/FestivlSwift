//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/24/23.
//

import Foundation
import FestivlDependencies
import FirebaseAuth
import Models

// MARK: AuthClient
extension SessionClient: DependencyKey {
    public static var liveValue = SessionClient.firebase
}

extension SessionClient {
    static public var firebase = SessionClient(
        publisher: { 
            SessionStore
                .shared
                .publisher
                .share()
                .eraseToAnyPublisher()
        },
        signIn: SessionStore.shared.signIn(_:),
        signUp: SessionStore.shared.signUp(_:),
        signOut: SessionStore.shared.signOut,
        selectOrganization: { SessionStore.shared.publisher.value?.selectedOrganization = $0 },
        selectEvent: { SessionStore.shared.publisher.value?.selectedEvent = $0 }
    )
}

import OSLog
extension Logger {
    static let auth = Logger(
        subsystem: "FestivlAuthentication",
        category: "firebase"
    )
}

private class SessionStore {
    static var shared = SessionStore()
    
    var handle: AuthStateDidChangeListenerHandle?
    var publisher: CurrentValueSubject<Session?, Never> = .init(nil)
    
    init() {
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            Logger.auth.debug(
                """
                Session Update:
                auth: \(auth)
                user: \(user)
                """
            )

            if let user {
                let session = Session(
                    user: User(id: .init(user.uid), email: user.email ?? "No Email"),
                    organization: nil, // TODO: Get out of UserDefaults?
                    event: nil // TODO: Same
                )
                
                self?.publisher.send(session)
            } else {
                self?.publisher.send(nil)
            }
        }
    }
    
    // MARK: Sign in/up/out
    // These functions don't interact with the SessionStore object itself,
    // instead they go through the Auth.auth() singleton firebase provides.
    // This mostly wraps them up cleanly into async throwing function
    func signIn(_ signInData: SignInUpData) async throws -> Models.User.ID {
        do {
            let response = try await Auth.auth().signIn(
                withEmail: signInData.email,
                password: signInData.password
            )

            return .init(response.user.uid)
        } catch let error as AuthErrorCode {
            throw error.toSignInErrror
        }
    }
    
    func signUp(_ signUpData: SignInUpData) async throws -> Models.User.ID {

        do {
            let response = try await Auth.auth().signIn(
                withEmail: signUpData.email,
                password: signUpData.password
            )

            return .init(response.user.uid)
        } catch let error as AuthErrorCode {
            throw error.toSignUpError
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch AuthErrorCode.keychainError {
            throw FestivlError.SignOutError.keychainError
        } catch {
            throw FestivlError.SignOutError.other
        }
    }
}

// MARK: Error Mapping
extension AuthErrorCode {
    var toSignInErrror: FestivlError.SignInError {
        switch self {
        case AuthErrorCode.operationNotAllowed: return .operationNotAllowed
        case AuthErrorCode.userDisabled: return .userDisabled
        case AuthErrorCode.wrongPassword: return .wrongPassword
        case AuthErrorCode.invalidEmail: return .invalidEmail
        default: return .other
        }
    }
    
    var toSignUpError: FestivlError.SignUpError {
        switch self {
        case AuthErrorCode.operationNotAllowed: return .operationNotAllowed
        case AuthErrorCode.emailAlreadyInUse: return .emailAlreadyInUse
        case AuthErrorCode.invalidEmail: return .invalidEmail
        case AuthErrorCode.weakPassword: return .weakPassword
        default: return .other
        }
    }
}

