//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/7/22.
//

import Foundation
import Models
import IdentifiedCollections
import DependenciesMacros
import XCTestDynamicOverlay
import Dependencies
import Combine

@DependencyClient
public struct ArtistClient {
    public var getArtists: () -> DataStream<IdentifiedArrayOf<Artist>> = { Empty().eraseToDataStream() }
    public var getArtist: (Event.ID, Artist.ID) -> DataStream<Artist> = { _, _ in Empty().eraseToDataStream() }
}

extension ArtistClient: TestDependencyKey {
    public static var testValue: ArtistClient = Self()

    public static var previewValue = ArtistClient(
        getArtists: {
            Just(Artist.testValues.asIdentifiedArray).eraseToDataStream()
        },
        getArtist: { _, _ in Just(Artist.previewData).eraseToDataStream() }
    )
}

public extension DependencyValues {
    var artistClient: ArtistClient {
        get { self[ArtistClient.self] }
        set { self[ArtistClient.self] = newValue }
    }
}
