//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/10/22.
//

import Foundation
import ComposableArchitecture
import Utilities
import SwiftUI


public enum ScheduleItemType: Equatable {
    case artistSet(ArtistID), groupSet([ArtistID])
}

public protocol ScheduleCardRepresentable: Identifiable, Equatable {
    var startTime: Date { get }
    var endTime: Date { get }
    var title: String { get }
    var subtext: String? { get }
    var type: ScheduleItemType { get }
}

public protocol ScheduleItemProtocol: ScheduleCardRepresentable {
    var stageID: String { get }
}

public extension ScheduleCardRepresentable {
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

        return Calendar.current.isDate(selectedDate, inSameDayAs: setStartTime)
    }
}

public extension ScheduleItem {
    func xPlacement(stageCount: Int, containerWidth: CGFloat, stages: IdentifiedArrayOf<Stage>) -> CGFloat {
        return containerWidth / CGFloat(stageCount) * CGFloat(stages.index(id: stageID)!)
    }
}

public struct ScheduleItem: ScheduleItemProtocol {
    public var stageID: StageID
    public var startTime: Date
    public var endTime: Date
    public var title: String
    public var subtext: String?
    public var id: String?

    public var type: ScheduleItemType

    public init<T: ScheduleItemProtocol>(_ representable: T) where T.ID == String? {
        self.stageID = representable.stageID
        self.startTime = representable.startTime
        self.endTime = representable.endTime
        self.title = representable.title
        self.subtext = representable.subtext
        self.id = representable.id
        self.type = representable.type
    }
}

public extension ScheduleItemProtocol where Self.ID == String? {
    func asScheduleItem() -> ScheduleItem {
        return .init(self)
    }
}
