//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/13/22.
//

import Foundation
import ComposableArchitecture

public typealias Schedule = [SchedulePageIdentifier: IdentifiedArrayOf<ScheduleItem>]



extension Schedule {
    public func scheduleItemsForArtist(artist: Artist) -> IdentifiedArrayOf<ScheduleItem> {
        values.flatMap {
            $0.filter {
                switch $0.type {
                case .artistSet(let artistID):
                    return artistID == artist.id

                case .groupSet(let artistIDs):
                    return artistIDs.contains(artist.id ?? "")
                }
            }
        }
        .asIdentifedArray
    }

    public mutating func insert(for key: Key, value: ScheduleItem) {
        if self.keys.contains(key) {
            self[key]?.append(value)
        } else {
            self[key] = .init()
            self[key]?.append(value)
        }
    }

    public func itemFor(itemID: String?) -> ScheduleItem? {
        for scheduleGroup in values {
            if let item = scheduleGroup[id: itemID] {
                return item
            }
        }

        return nil
    }

}

public struct SchedulePageIdentifier: Hashable {
    public init(date: Date, stageID: StageID) {
        self.date = date
        self.stageID = stageID
    }

    public var date: Date
    public var stageID: StageID
}
