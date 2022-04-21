//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/10/22.
//

import Foundation
import FirebaseFirestoreSwift
import Utilities
import Foundation
import ComposableArchitecture
import SwiftUI

public struct GroupSet: Identifiable, Codable, Equatable {

    public init(
        name: String,
        artists: [Artist],
        stageID: StageID,
        startTime: Date,
        endTime: Date
    ) {
        self.name = name
        self.artistIDs = artists.compactMap(\.id)
        self.artistNames = artists.map(\.name)
        self.stageID = stageID
        self.startTime = startTime
        self.endTime = endTime
    }
    
    @DocumentID public var id: String?

    public var name: String
    public var artistIDs: [ArtistID]
    public var artistNames: [String]
    public var stageID: StageID
    public var startTime: Date
    public var endTime: Date
}

extension GroupSet: ScheduleItemProtocol {
    public var title: String {
        return name
    }

    public var subtext: String? {
        if artistNames.allSatisfy({ title.contains($0) }) {
            return nil
        } else {
            return artistNames.joined(separator: ", ")
        }
    }

    public var type: ScheduleItemType {
        .groupSet(artistIDs)
    }
}


