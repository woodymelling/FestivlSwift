//
//  OrganizationsClient.swift
//  
//
//  Created by Woodrow Melling on 8/13/23.
//

import Foundation
import DependenciesMacros
import Models

@DependencyClient
public struct OrganizationClient {
    public var observeMyOrganizations: () -> DataStream<IdentifiedArrayOf<Organization>> = { Empty().eraseToDataStream() }
    public var observeAllOrganizations: () -> DataStream<IdentifiedArrayOf<Organization>> = { Empty().eraseToDataStream() }
    public var createOrganization: (_ name: String, _ imageURL: URL?, _ owner: User.ID) async throws -> Organization
}

extension OrganizationClient: TestDependencyKey {

    public static var testValue = OrganizationClient()
    
    public static var previewValue: OrganizationClient = OrganizationClient(
        observeMyOrganizations: { InMemoryOrganizationStore.shared.$organizations.eraseToDataStream() },
        observeAllOrganizations: { InMemoryOrganizationStore.shared.$organizations.eraseToDataStream() },
        createOrganization: InMemoryOrganizationStore.shared.createOrganization(name: imageURL: owner:)
    )
}

public extension DependencyValues {
    var organizationClient: OrganizationClient {
        get { self[OrganizationClient.self] }
        set { self[OrganizationClient.self] = newValue }
    }
}

class InMemoryOrganizationStore {
    static var shared = InMemoryOrganizationStore()

    init() {}

    @Published var organizations = Organization.previewValues

    func createOrganization(name: String, imageURL: URL?, owner: User.ID) -> Organization {
        @Dependency(\.uuid) var uuid
        let org = Organization(
            id: .init(uuid().uuidString),
            name: name,
            imageURL: imageURL,
            userRoles: [owner : .owner]
        )

        organizations.append(org)
        return org
    }
}
