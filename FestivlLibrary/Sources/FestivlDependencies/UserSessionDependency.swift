//
//  UserSessionDependency.swift
//  
//
//  Created by Woodrow Melling on 8/2/23.
//

import Foundation
import Dependencies
import Models

extension Session: DependencyKey {
    public static var liveValue: Session? = nil
    public static var testValue: Session? = unimplemented("User.ID")
}

extension DependencyValues {
    public var session: Session? {
        get { self[Session.self] }
        set { self[Session.self] = newValue }
    }
}
