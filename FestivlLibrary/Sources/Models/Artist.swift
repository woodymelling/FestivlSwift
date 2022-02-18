//
//  Artist.swift
//  
//
//  Created by Woody on 2/9/22.
//

import Foundation
import FirebaseFirestoreSwift

public typealias ArtistID = String


public struct Artist: Codable, Identifiable {
    public init(
        id: ArtistID? = nil,
        name: String,
        description: String? = nil,
        tier: Int? = nil,
        imageURL: URL? = nil,
        soundcloudURL: String? = nil,
        websiteURL: String? = nil,
        spotifyURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.tier = tier
        self.imageURL = imageURL
        self.soundcloudURL = soundcloudURL
        self.websiteURL = websiteURL
        self.spotifyURL = spotifyURL
    }

    @DocumentID public var id: ArtistID?
    public var name: String
    public var description: String?
    public var tier: Int?
    public var imageURL: URL?
    public var soundcloudURL: String?
    public var websiteURL: String?
    public var spotifyURL: String?

}

extension Artist: Equatable {
    public static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs._id == rhs._id
    }
}

extension Artist {
    public static var testData: Artist {
        return Artist(
            id: "23515",
            name: "Rhythmbox",
            description: "Chunky house grooves, with an injection of funk and disco", tier: 0,
            imageURL: URL(string: "https://i1.sndcdn.com/avatars-SknftjiekzKlQO2q-DkmFhQ-t500x500.jpg"),
            soundcloudURL: "https://soundcloud.com/rythm_box",
            websiteURL: "www.google.com",
            spotifyURL: "www.spotify.com"
        )
    }

    public static var testValues: [Artist] {
        [
            .testData,

            Artist(
                id: "000000",
                name: "Abstrakt Sonance",
                description: "A sound design enthusiast, Abstrakt Sonance is a passionate and boundary pushing producer. Pushing soundsystem culture in Canada for over 10 years, from running his own nights, labels, and now traveling the globe. Touring 4 continents consistently, sets ever evolving, never even close to the same.",
                tier: 0,
                imageURL: URL(string: "https://www.stereofox.com/wp-content/uploads/2021/06/62e2a8f767578d02f208e5e93db0e26b43846243.jpg")!,
                soundcloudURL: "https://soundcloud.com/ABSTRAKTSONANCE",
                websiteURL: "https://abstraktsonance.bandcamp.com",
                spotifyURL: "https://open.spotify.com/artist/00qKBesewdWy5l0bpMdosp"
            )
        ]
    }
}
