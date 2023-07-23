//
//  Artist.swift
//  
//
//  Created by Woody on 2/9/22.
//

import Foundation
import Tagged
import Utilities
import IdentifiedCollections

public struct Artist: Codable, Hashable, Identifiable {
    public init(
        id: Artist.ID,
        name: String,
        description: String? = nil,
        tier: Int? = nil,
        imageURL: URL? = nil,
        soundcloudURL: String? = nil,
        websiteURL: String? = nil,
        spotifyURL: String? = nil,
        instagramURL: String? = nil,
        facebookURL: String? = nil,
        youtubeURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.tier = tier
        self.imageURL = imageURL
        self.soundcloudURL = soundcloudURL
        self.websiteURL = websiteURL
        self.spotifyURL = spotifyURL
        self.instagramURL = instagramURL
        self.facebookURL = facebookURL
        self.youtubeURL = youtubeURL
    }

    public var id: Tagged<Artist, String>
    public var name: String
    public var description: String?
    public var tier: Int?
    public var imageURL: URL?
    public var soundcloudURL: String?
    public var websiteURL: String?
    public var spotifyURL: String?
    public var youtubeURL: String?
    public var instagramURL: String?
    public var facebookURL: String?

}

extension Artist {
    public static var previewData: Artist {
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

    public static var testValues: [Artist] = generateRandomArtistData()
        
    
}

// Function to generate random artists with a seeded RNG
func generateRandomArtistData() -> [Artist] {
    let names = [
        "Abstrakt Sonance",
        "Orion Moon",
        "Lyrsense",
        "Electra",
        "Max Rhythm",
        "Stella Synth",
        "Echo Nova",
        "Luna Blaze",
        "Harmonix",
        "Astrid",
        "Soundwaves",
        "Soleil Beats",
        "Sapphira",
        "Luminous Vox",
        "Aurelia Pulse",
        "DJ Pulsewave",
        "Cosmic Groove",
        "DiscoBot",
        "Synthex",
        "Rhythmix",
        "Muse Whisperer",
        "Dreamweaver Jazz",
        "Tranquil Mist",
        "Glimmer Sound",
        "Rhapsody Dawn",
        "Stellar Pulse",
        "Neon Sky",
        "Enchanted Echo",
        "Satori Melody",
        "Zen Rhapsody",
        "Vesper",
    ]
    .sorted()
    
    var artists = [Artist]()
    
    var rng = RandomNumberGeneratorWithSeed(seed: 12345) // Use any seed value you like
    
    for name in names {
        let id = "ID\(name)"
        let description = Bool.random(using: &rng) ? "Description for \(name)" : nil
        let tier = Bool.random(using: &rng) ? Int.random(in: 1...3, using: &rng) : nil
        let imageURL = Bool.random(using: &rng) ? URL(string: "https://example.com/\(name.replacingOccurrences(of: " ", with: "_"))") : nil
        let soundcloudURL = Bool.random(using: &rng) ? "https://soundcloud.com/\(name.replacingOccurrences(of: " ", with: "-"))" : nil
        let websiteURL = Bool.random(using: &rng) ? "https://\(name.replacingOccurrences(of: " ", with: "").lowercased())music.com" : nil
        let spotifyURL = Bool.random(using: &rng) ? "https://open.spotify.com/artist/\(name.replacingOccurrences(of: " ", with: ""))" : nil
        let youtubeURL = Bool.random(using: &rng) ? "https://www.youtube.com/\(name.replacingOccurrences(of: " ", with: ""))" : nil
        let instagramURL = Bool.random(using: &rng) ? "https://www.instagram.com/\(name.replacingOccurrences(of: " ", with: "_"))" : nil
        let facebookURL = Bool.random(using: &rng) ? "https://www.facebook.com/\(name.replacingOccurrences(of: " ", with: "-"))" : nil
        
        let artist = Artist(
            id: .init(id),
            name: name,
            description: description,
            tier: tier,
            imageURL: imageURL,
            soundcloudURL: soundcloudURL,
            websiteURL: websiteURL,
            spotifyURL: spotifyURL,
            instagramURL: instagramURL,
            facebookURL: facebookURL,
            youtubeURL: youtubeURL
        )
        
        artists.append(artist)
    }
    
    return artists
}


extension Artist: Searchable {
    public var searchTerms: [String] {
        [name]
    }
}

extension IdentifiedArrayOf<Artist> {
    public static var previewData: IdentifiedArrayOf<Artist> {
        IdentifiedArray(uniqueElements: Artist.testValues)
    }
}


struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    init(seed: Int) {
        // Set the random seed
        srand48(seed)
    }
    
    func next() -> UInt64 {
        // drand48() returns a Double, transform to UInt64
        return withUnsafeBytes(of: drand48()) { bytes in
            bytes.load(as: UInt64.self)
        }
    }
}
