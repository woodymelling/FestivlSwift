//
//  OrganizationsClient.swift
//  
//
//  Created by Woodrow Melling on 8/13/23.
//

import Foundation
import Models

public struct OrganizationClient {
    public var observeMyOrganizations: () -> DataStream<IdentifiedArrayOf<Organization>>
    public var observeAllOrganizations: () -> DataStream<IdentifiedArrayOf<Organization>>
    public var createOrganization: (String, URL?, User.ID) async throws -> Organization

    public init(
        observeMyOrganizations: @escaping () -> DataStream<IdentifiedArrayOf<Organization>>,
        observeAllOrganizations: @escaping () -> DataStream<IdentifiedArrayOf<Organization>>,
        createOrganization: @escaping (String, URL?, User.ID) async throws -> Organization
    ) {
        self.observeMyOrganizations = observeMyOrganizations
        self.observeAllOrganizations = observeAllOrganizations
        self.createOrganization = createOrganization
    }

    public func createOrganization(name: String, imageURL: URL? = nil, owner: User.ID) async throws -> Organization {
        try await self.createOrganization(name, imageURL, owner)
    }
}

extension OrganizationClient: TestDependencyKey {

    public static var testValue = OrganizationClient(
        observeMyOrganizations: unimplemented("OrganizationClient.fetchMyOrganizations"),
        observeAllOrganizations: unimplemented("OrganizationClient.fetchMyOrganizations"),
        createOrganization: unimplemented("OrganizationClient.createOrganization")
    )

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
