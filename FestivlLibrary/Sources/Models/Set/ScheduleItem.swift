//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/10/22.
//

import Foundation
import SwiftUI
import IdentifiedCollections
import Utilities
import Tagged
import CustomDump
import Collections


public struct ScheduleItem: Identifiable, Hashable {
    public init(
        id: Tagged<ScheduleItem, String>,
        stageID: Stage.ID,
        startTime: Date,
        endTime: Date,
        title: String,
        subtext: String? = nil,
        type: ItemType
    ) {
        self.stageID = stageID
        self.startTime = startTime
        self.endTime = endTime
        self.title = title
        self.subtext = subtext
        self.id = id
        self.type = type
    }
    
    public var id: Tagged<Self, String>
    public var stageID: Stage.ID
    public var startTime: Date
    public var endTime: Date
    
    public var timeInterval: DateInterval { .init(start: startTime, end: endTime) }
    
    public var title: String
    public var subtext: String?

    public var type: ItemType
    
    public enum ItemType: Equatable, Codable {
        case artistSet(Artist.ID)
        case groupSet([Artist.ID])
    }
    
    public func schedulePageIdentifier(dayStartsAtNoon: Bool, timeZone: TimeZone) -> Schedule.PageKey {
        let dateForScheduleItem: CalendarDate
        
        if dayStartsAtNoon {
            dateForScheduleItem = CalendarDate(date: startTime - 12.hours, timeZone: timeZone)
        } else {
            dateForScheduleItem = CalendarDate(date: startTime, timeZone: timeZone)
        }
        
        return .init(date: dateForScheduleItem, stageID: stageID)
    }
}

public extension ScheduleItem {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ScheduleItem {
    
    public static var previewData: IdentifiedArrayOf<ScheduleItem> {
        return previewData()
    }
    
    public static func previewData(
        artists: [Artist] = Artist.testValues,
        stages: [Stage] = Stage.previewData,
        setLengthMinutes: Int = 60,
        startTime: Date = Calendar.current.date(from: DateComponents(hour: 13))!
    ) ->  IdentifiedArrayOf<ScheduleItem> {
        IdentifiedArray(uniqueElements: artists.enumerated().map { idx, artist in
            
            let startTime = Calendar.current.date(byAdding: .minute, value: setLengthMinutes * idx, to: startTime)!
            let endTime = Calendar.current.date(byAdding: .minute, value: setLengthMinutes, to: startTime)!
            
            return ScheduleItem(
                id: .init(String(idx)),
                stageID: stages[wrapped: idx].id,
                startTime: startTime,
                endTime: endTime,
                title: artist.name,
                type: .artistSet(artist.id)
            )
        })
    }
    
    
    func isOnDate(_ date: Date, dayStartsAtNoon: Bool) -> Bool {
        let selectedDate = date.startOfDay(dayStartsAtNoon: false)
        let setStartTime: Date

        if dayStartsAtNoon {
            setStartTime = startTime - 12.hours
        } else {
            setStartTime = startTime
        }
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.default

        return  calendar.isDate(selectedDate, inSameDayAs: setStartTime)
    }
}
