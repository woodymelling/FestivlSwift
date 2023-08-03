//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/24/23.
//

import Foundation

public struct Session: Identifiable, Equatable {
    public init(user: Session.User) {
        self.user = user
    }
    
    public var user: Session.User
    public var id: Session.User.ID { user.id }
    
    
    // MARK: User
    public struct User: Identifiable, Equatable {
        public var id: Tagged<Self, String>
        public var email: String
        
        public init(id: Self.ID, email: String) {
            self.id = id
            self.email = email
        }
    }
}
