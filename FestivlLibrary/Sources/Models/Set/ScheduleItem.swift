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

public enum ScheduleItemType: Equatable, Codable {
    case artistSet(Artist.ID), groupSet([Artist.ID])
}

public extension ScheduleItem {
    func xPlacement(stageCount: Int, containerWidth: CGFloat, stages: IdentifiedArrayOf<Stage>) -> CGFloat {
        return containerWidth / CGFloat(stageCount) * CGFloat(stages.index(id: stageID)!)
    }
    
    var setLength: TimeInterval {
        endTime.timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate
    }

    /// Get the frame size for an artistSet in a specfic container
    func size(in containerSize: CGSize, stageCount: Int) -> CGSize {
        let setLengthInSeconds = endTime.timeIntervalSince(startTime)
        let height = secondsToY(Int(setLengthInSeconds), containerHeight: containerSize.height)
        let width = containerSize.width / CGFloat(stageCount)
        return CGSize(width: width, height: height)
    }

    /// Get the y placement for a set in a container of a specific height
    func yPlacement(dayStartsAtNoon: Bool, containerHeight: CGFloat) -> CGFloat {
        return startTime.toY(containerHeight: containerHeight, dayStartsAtNoon: dayStartsAtNoon)
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

public struct ScheduleItem: SimpleSetConvertible, Codable, Hashable {
    public init(
        id: Tagged<ScheduleItem, String>,
        stageID: Stage.ID,
        startTime: Date,
        endTime: Date,
        title: String,
        subtext: String? = nil,
        type: ScheduleItemType
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
    public var title: String
    public var subtext: String?

    public var type: ScheduleItemType

}

public extension ScheduleItem {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ScheduleItem {
    
    public static func testValues(
        artists: [Artist] = Artist.testValues,
        stages: [Stage] = Stage.testValues,
        count: Int = 10,
        setLengthMinutes: Int = 60,
        startTime: Date = Calendar.current.date(from: DateComponents(hour: 13))!
    ) ->  Set<ScheduleItem> {
        Set((0...count).map {
            let artist = artists[wrapped: $0]
            
            let startTime = Calendar.current.date(byAdding: .minute, value: setLengthMinutes * $0, to: startTime)!
            let endTime = Calendar.current.date(byAdding: .minute, value: setLengthMinutes, to: startTime)!
            
            return ScheduleItem(
                id: .init(String($0)),
                artistID: artist.id,
                artistName: artist.name,
                stageID: stages[wrapped: $0].id,
                startTime: startTime,
                endTime: endTime
            )
        })
    }
}

