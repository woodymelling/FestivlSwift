//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/24/23.
//

import Foundation

public struct SignInUpData {
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    public var email: String
    public var password: String
}
