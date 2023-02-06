//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/7/22.
//

import Foundation
import Models
import IdentifiedCollections
import XCTestDynamicOverlay
import Dependencies
import Combine

public struct ArtistClient {
    public init(
        getArtists: @escaping (Event.ID) -> DataStream<IdentifiedArrayOf<Artist>>,
        getArtist: @escaping (Event.ID, Artist.ID) -> DataStream<Artist>
    ) {
        self.getArtists = getArtists
        self.getArtist = getArtist
    }
    
    public var getArtists: (Event.ID) -> DataStream<IdentifiedArrayOf<Artist>>
    public var getArtist: (Event.ID, Artist.ID) -> DataStream<Artist>
}

public enum ArtistClientKey: TestDependencyKey {
    public static var testValue = ArtistClient(
        getArtists: unimplemented("ArtistClient.getArtists"),
        getArtist: unimplemented("ArtistClient.getArtist")
    )
    
    public static var previewValue = ArtistClient(
        getArtists: { _ in Just(Artist.testValues.asIdentifedArray).eraseToDataStream() },
        getArtist: { _, _ in Just(Artist.testData).eraseToDataStream() }
    )
}

public extension DependencyValues {
    var artistClient: ArtistClient {
        get { self[ArtistClientKey.self] }
        set { self[ArtistClientKey.self] = newValue }
    }
}
