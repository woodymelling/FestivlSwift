//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import FirebaseFirestoreSwift
import Utilities
import Foundation
import ComposableArchitecture
import SwiftUI

public struct ArtistSet: Identifiable, Codable, Equatable {

    @DocumentID public var id: String?
    public var artistID: ArtistID
    public var artistName: String
    public var stageID: StageID
    public var startTime: Date
    public var endTime: Date

    public init(
        id: String?,
        artistID: ArtistID,
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

extension ArtistSet: ScheduleItemProtocol {
    public var title: String {
        artistName
    }

    public var subtext: String? {
        nil
    }

    public var type: ScheduleItemType {
        .artistSet(artistID)
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

    public static func testValues(
        artists: [Artist] = Artist.testValues,
        stages: [Stage] = Stage.testValues,
        count: Int = 10,
        setLengthMinutes: Int = 60,
        startTime: Date = Calendar.current.date(from: DateComponents(hour: 13))!
    ) ->  [ArtistSet] {
        (0...count).map {
            let artist = artists[wrapped: $0]

            let startTime = Calendar.current.date(byAdding: .minute, value: setLengthMinutes * $0, to: startTime)!
            let endTime = Calendar.current.date(byAdding: .minute, value: setLengthMinutes, to: startTime)!

            return ArtistSet(
                id: String($0),
                artistID: artist.id!,
                artistName: artist.name,
                stageID: stages[wrapped: $0].id!,
                startTime: startTime,
                endTime: endTime
            )
        }
    }
}


