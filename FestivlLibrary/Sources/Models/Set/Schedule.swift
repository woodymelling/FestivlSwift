//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/19/22.
//

import Foundation
import Utilities
import Tagged
import CustomDump
import IdentifiedCollections
import Collections

/// A  collection of ScheduleItems indexed for each artist, and each schedule page.
/// This allows for O(1) access to all ScheduleItems associated with an artist or with a stage/date combination,
/// at the cost of additional space complexity, and an O(N) index generation at each update
public struct Schedule: Equatable, Collection {
    
    public struct PageKey: Hashable, Codable {
        public init(date: CalendarDate, stageID: Stage.ID) {
            self.date = date
            self.stageID = stageID
        }

        public var date: CalendarDate
        public var stageID: Stage.ID
    }
    
    
    public typealias ScheduleItemStore = IdentifiedArrayOf<ScheduleItem>
    
    private let scheduleItems: ScheduleItemStore
    
    private let artistIndex: [Artist.ID : Set<ScheduleItem.ID>]
    private let schedulePageIndex: [PageKey : Set<ScheduleItem.ID>]
    public let dayStartsAtNoon: Bool
    
    
    public init(scheduleItems: IdentifiedArrayOf<ScheduleItem>, dayStartsAtNoon: Bool, timeZone: TimeZone) {
        self.dayStartsAtNoon = dayStartsAtNoon
        var artistIndex: [Artist.ID : Set<ScheduleItem.ID>] = [:]
        var schedulePageIndex: [PageKey : Set<ScheduleItem.ID>] = [:]
        var items = IdentifiedArrayOf<ScheduleItem>()
        
        for scheduleItem in scheduleItems {
            
            items.append(scheduleItem)
            
            // Populate schedule page index
            schedulePageIndex.insert(
                key: scheduleItem.schedulePageIdentifier(dayStartsAtNoon: dayStartsAtNoon, timeZone: timeZone),
                value: scheduleItem.id
            )
            
            // Populate artistPage index
            switch scheduleItem.type {
            case .artistSet(let artistID):
                artistIndex.insert(key: artistID, value: scheduleItem.id)
            case .groupSet(let artistIDs):
                for artistID in artistIDs {
                    artistIndex.insert(key: artistID, value: scheduleItem.id)
                }
            }
        }
        
        self.artistIndex = artistIndex
        self.schedulePageIndex = schedulePageIndex
        self.scheduleItems = items
    }
    
    public subscript(artistID artistID: Artist.ID) -> OrderedSet<ScheduleItem> {
        guard let scheduleItemIds = artistIndex[artistID] else { return .init() }
        
        return scheduleItemIds.reduce(into: OrderedSet()) { partialResult, scheduleItemID in
            if let scheduleItem = scheduleItems[id: scheduleItemID] {
                partialResult.append(scheduleItem)
            }
        }
    }
    
//    public subscript(page schedulePage: PageKey) -> OrderedSet<ScheduleItem> {
//        guard let scheduleItemIds = schedulePageIndex[schedulePage] else { return .init() }
//        
//        return scheduleItemIds.reduce(into: OrderedSet()) { partialResult, scheduleItemID in
//            if let scheduleItem = scheduleItems[id: scheduleItemID] {
//                partialResult.append(scheduleItem)
//            }
//        }
//    }
    
    public subscript(page schedulePage: PageKey) -> IdentifiedArrayOf<ScheduleItem> {
        guard let scheduleItemIds = schedulePageIndex[schedulePage] else { return .init() }
        
        return IdentifiedArray(uncheckedUniqueElements: scheduleItemIds.reduce(into: OrderedSet()) { partialResult, scheduleItemID in
            if let scheduleItem = scheduleItems[id: scheduleItemID] {
                partialResult.append(scheduleItem)
            }
        })
    }
    
    public subscript(id id: ScheduleItem.ID) -> ScheduleItem? {
        scheduleItems[id: id]
    }
}

extension Schedule {
    
    public typealias Index = ScheduleItemStore.Index
    public typealias Element = ScheduleItem
    
    public var startIndex: Index {
        return scheduleItems.startIndex
    }
    
    public var endIndex: Index {
        return scheduleItems.endIndex
    }
    
    public subscript(position: Index) -> ScheduleItem {
        get { scheduleItems[position] }
    }
    
    public func index(after i: Index) -> Index {
        scheduleItems.index(after: i)
    }
}
//
//public extension Set where Element == ScheduleItem {
//    var sortedByStartTime: [ScheduleItem] {
//        return Array(self).sorted(by: { $0.startTime > $1.startTime})
//    }
//}

extension Dictionary where Value == Set<ScheduleItem.ID> {
    mutating func insert(key: Key, value: ScheduleItem.ID) {
        if self.keys.contains(key) {
            self[key]?.insert(value)
        } else {
            self[key] = .init()
            self[key]?.insert(value)
        }
    }
}


extension Schedule: CustomDumpStringConvertible {
    public var customDumpDescription: String {
        return "Schedule(...)"
    }
}

extension Schedule {

    public static var previewData: Schedule = Schedule(
        scheduleItems: ScheduleItem.previewData,
        dayStartsAtNoon: false,
        timeZone: .current
    )
}
