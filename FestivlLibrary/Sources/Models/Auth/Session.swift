//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/24/23.
//

import Foundation

public struct Session: Identifiable, Equatable {
    public init(
        user: User,
        organization: Organization.ID?,
        event: Event.ID?
    ) {
        self.user = user
    }
    
    public var user: User
    public var id: User.ID { user.id }
    public var selectedOrganization: Organization.ID?
    public var selectedEvent: Event.ID?
}


// MARK: User
public struct User: Identifiable, Equatable {
    public var id: Tagged<Self, String>
    public var email: String

    public init(id: Self.ID, email: String) {
        self.id = id
        self.email = email
    }

}

extension User {
    public enum Role {
        case owner
        case admin
    }
}

public typealias UserRoles = [User.ID: User.Role]
