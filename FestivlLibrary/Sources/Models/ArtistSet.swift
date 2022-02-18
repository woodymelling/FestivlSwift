//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import FirebaseFirestoreSwift
import Utilities
import Foundation

public struct ArtistSet: Identifiable, Codable, Equatable {

    @DocumentID public var id: String?
    public var artistID: Artist.ID
    public var artistName: String
    public var stageID: StageID
    public var startTime: Date
    public var endTime: Date

    public init(
        id: String?,
        artistID: Artist.ID,
        artistName: String,
        stageID: StageID,
        startTime: Date,
        endTime: Date
    ) {
        self.id = id
        self.artistID = artistID
        self.artistName = artistName
        self.stageID = stageID
        self.startTime = startTime
        self.endTime = endTime
    }
}

extension ArtistSet {
    public static var testData: ArtistSet {
        return ArtistSet(
            id: nil,
            artistID: "",
            artistName: "Rythmbox",
            stageID: "0",
            startTime: Date(),
            endTime: Date() + 1.hours
        )
    }
}
