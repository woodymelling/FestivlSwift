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
        getArtists: @escaping () -> DataStream<IdentifiedArrayOf<Artist>>,
        getArtist: @escaping (Event.ID, Artist.ID) -> DataStream<Artist>
    ) {
        self.getArtists = getArtists
        self.getArtist = getArtist
    }
    
    public var getArtists: () -> DataStream<IdentifiedArrayOf<Artist>>
    public var getArtist: (Event.ID, Artist.ID) -> DataStream<Artist>
}

public enum ArtistClientKey: TestDependencyKey {
    public static var testValue = ArtistClient(
        getArtists: unimplemented("ArtistClient.getArtists"),
        getArtist: unimplemented("ArtistClient.getArtist")
    )
    
    public static var previewValue = ArtistClient(
        getArtists: {
            Just(Artist.testValues.asIdentifiedArray).eraseToDataStream()
        },
        getArtist: { _, _ in Just(Artist.previewData).eraseToDataStream() }
    )
}

public extension DependencyValues {
    var artistClient: ArtistClient {
        get { self[ArtistClientKey.self] }
        set { self[ArtistClientKey.self] = newValue }
    }
}
