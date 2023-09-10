//
//  File.swift
//  
//
//  Created by Woodrow Melling on 9/9/23.
//

import Foundation
import Utilities
import FestivlDependencies
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth

extension OrganizationClient: DependencyKey {
    public static var firebaseClient = OrganizationClient(
        observeMyOrganizations: {
            guard let userID = Auth.auth().currentUser?.uid
            else { return .throwing(.authorization(.notLoggedIn)) }

           return FirebaseService.observeQuery(
                db.collection("organizations").whereField("userRoles", arrayContains: userID),
                mapping: Organization.init(dto:)
            )
        },
        observeAllOrganizations: {
            return FirebaseService.observeQuery(
                db.collection("organizations").whereField("isPublic", isEqualTo: true),
                mapping: Organization.init(dto:)
            )
        },
        createOrganization: { eventName, imageURL, owner in
            let organization = Organization.DTO(
                name: eventName,
                imageURL: imageURL,
                isPublic: false,
                userRoles: [owner: .owner]
            )

            let doc = try await FirebaseService.createDocument(
                reference: db.collection("organizations"),
                data: organization
            )

            return try await doc.getDocument(as: Organization.DTO.self) |> Organization.init
        }
    )

    public static var liveValue: OrganizationClient = .firebaseClient

}


extension Organization {
    struct DTO: Codable {
        @DocumentID var id: String?
        let name: String
        let imageURL: URL?

        let isPublic: Bool
        let userRoles: [Models.User.ID : UserRole]


        enum UserRole: Codable {
            case owner, admin
        }
    }
}

extension Models.User.Role {
    init(dto: Organization.DTO.UserRole) {
        self = switch dto {
        case .admin: .admin
        case .owner: .owner
        }
    }
}

extension Organization {
    init(dto: Organization.DTO) throws {
        self.init(
            id: try Organization.ID(dto.id ?! FestivlError.DecodingError.noID),
            name: dto.name,
            imageURL: dto.imageURL,
            userRoles: dto.userRoles.mapValues { User.Role(dto: $0) },
            isPublic: dto.isPublic
        )
    }
}

infix operator ?!: NilCoalescingPrecedence

/// Throws the right hand side error if the left hand side optional is `nil`.
func ?!<T>(value: T?, error: @autoclosure () -> Error) throws -> T {
    guard let value = value else {
        throw error()
    }
    return value
}

public func |> <A, B> (a: A, f: (A) throws -> B) throws -> B {
  return try f(a)
}


extension DataStream {
    static func throwing<T>(_ error: FestivlError) -> DataStream<T> {
        return Fail(outputType: T.self, failure: error).eraseToAnyPublisher()
    }
}
