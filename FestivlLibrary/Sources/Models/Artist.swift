//
//  Artist.swift
//  
//
//  Created by Woody on 2/9/22.
//

import Foundation
import FirebaseFirestoreSwift


public struct Artist: Codable, Identifiable, Hashable {
    public init(
        id: String? = nil,
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

    @DocumentID public var id: String?
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
}
