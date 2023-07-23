//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Models
import FirebaseFirestore
import FirebaseFirestoreSwift
import FestivlDependencies
import Dependencies

struct FirebaseArtistDTO: Codable {
    @DocumentID var id: String?
    var name: String
    var description: String?
    var tier: Int?
    var imageURL: URL?
    var soundcloudURL: String?
    var websiteURL: String?
    var spotifyURL: String?
    var instagramURL: String?
    var youtubeURL: String?
    var facebookURL: String?
    
    static var asArtist: (Self) -> Artist = {
        Artist(
            id: .init($0.id ?? ""),
            name: $0.name,
            description: $0.description,
            tier: $0.tier,
            imageURL: $0.imageURL,
            soundcloudURL: $0.soundcloudURL,
            websiteURL: $0.websiteURL,
            spotifyURL: $0.spotifyURL,
            instagramURL: $0.instagramURL,
            facebookURL: $0.facebookURL,
            youtubeURL: $0.youtubeURL
        )
    }
}

extension ArtistClientKey: DependencyKey {
    public static var liveValue = ArtistClient(
        getArtists: {
            @Dependency(\.eventID) var eventID
            
            return FirebaseService.observeQuery(
                db.collection("events").document(eventID.rawValue).collection("artists").order(by: "name"),
                mapping: FirebaseArtistDTO.asArtist
            )
        },
        getArtist: { eventID, artistID in
            FirebaseService.observeDocument(
                db.collection("events").document(eventID.rawValue).collection("artists").document(artistID.rawValue),
                mapping: FirebaseArtistDTO.asArtist
            )
            
        }
    )
}
