//
//  Organization.swift
//  
//
//  Created by Woodrow Melling on 8/13/23.
//

import Foundation
import Tagged
import Utilities

public struct Organization: Equatable, Identifiable {
    public var id: Tagged<Self, String>
    public var name: String
    public var imageURL: URL?
    
    public var isPublic: Bool
    public var userRoles: [User.ID : User.Role]

    public init(
        id: Tagged<Self, String>,
        name: String,
        imageURL: URL? = nil,
        userRoles: [User.ID: User.Role],
        isPublic: Bool = false
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.userRoles = userRoles
        self.isPublic = isPublic
    }
}

extension Organization: Searchable {
    public var searchTerms: [String] {
        [name]
    }
}

extension Organization {
    public static var previewValues: IdentifiedArrayOf<Organization> {
        [
            Organization(
                id: .init(1),
                name: "Wicked Woods",
                imageURL: URL(
                    string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F54F37A50-9698-41B3-AF27-2BC3EE1599FD.png?alt=media&token=d8b07305-f201-4826-bb91-1f31e209741f"
                ),
                userRoles: [:]
            ),
            Organization(
                id: .init(2),
                name: "Shambhala",
                imageURL: URL(
                    string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F0A2EA540-3861-4540-8B22-C064D8646925.png?alt=media&token=a89a0501-d455-4391-9fb0-31ad0a7ddff8"
                ),
                userRoles: [:]
            ),
            Organization(
                id: .init(3),
                name: "Testivl",
                imageURL: URL(
                    string: "https://media.discordapp.net/attachments/1065512392806645760/1137229657943588935/woody2583_icon_for_this_sentence_Amplify_the_festival_experienc_0c8d2733-dbbc-41f4-bf9a-964fa56f5009.png?width=1378&height=1378"
                ),
                userRoles: [:]
            ),
        ]
    }
}
