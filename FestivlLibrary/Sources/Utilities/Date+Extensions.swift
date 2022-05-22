//
//  File.swift
//  
//
//  Created by Woody on 2/20/22.
//

import Foundation
import SwiftUI

public extension Date {
    func startOfDay(dayStartsAtNoon: Bool) -> Date {

        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.default

        if dayStartsAtNoon {
            return calendar.startOfDay(for: self - 12.hours) + 12.hours
        } else {
            return calendar.startOfDay(for: self)
        }
    }

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

    func round(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .toNearestOrAwayFromZero)
    }

    func ceil(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .up)
    }

    func floor(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .down)
    }

    func round(precision: TimeInterval, rule: FloatingPointRoundingRule) -> Date {
        let seconds = (self.timeIntervalSinceReferenceDate / precision).rounded(rule) *  precision;
        return Date(timeIntervalSinceReferenceDate: seconds)
    }
}

public extension Date {
    func toY(containerHeight: CGFloat, dayStartsAtNoon: Bool) -> CGFloat {

        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = NSTimeZone.default
        

        var hoursIntoTheDay = calendar.component(.hour, from: self)
        let minutesIntoTheHour = calendar.component(.minute, from: self)

        if dayStartsAtNoon {
            // Shift the hour start by 12 hours, we're doing nights, not days
            hoursIntoTheDay = (hoursIntoTheDay + 12) % 24
        }

        let hourInSeconds = hoursIntoTheDay * 60 * 60
        let minuteInSeconds = minutesIntoTheHour * 60

        return secondsToY(hourInSeconds + minuteInSeconds, containerHeight: containerHeight)
    }
}


/// Get the y placement for a specific numbers of seconds
public func secondsToY(_ seconds: Int, containerHeight: CGFloat) -> CGFloat {
    let dayInSeconds: CGFloat = 86400
    let progress = CGFloat(seconds) / dayInSeconds
    return containerHeight * progress
}
