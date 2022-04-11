//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/10/22.
//

import Foundation
import ComposableArchitecture
import Utilities

public protocol ScheduleCardRepresentable {
    var startTime: Date { get }
    var endTime: Date { get }
    var title: String { get }
    var subtext: String? { get }
}

public protocol StageScheduleCardRepresentable: ScheduleCardRepresentable {
    var stageID: StageID { get }
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

public extension StageScheduleCardRepresentable {
    func xPlacement(stageCount: Int, containerWidth: CGFloat, stages: IdentifiedArrayOf<Stage>) -> CGFloat {
        return containerWidth / CGFloat(stageCount) * CGFloat(stages.index(id: stageID)!)
    }
}
