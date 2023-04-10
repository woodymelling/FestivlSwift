//
//  File.swift
//  
//
//  Created by Woody on 2/16/22.
//

import Foundation
import Utilities

public enum FestivlFormatting {
    
    public static func weekdayFormat(for day: CalendarDate) -> String {
        return weekdayFormat(for: day.date)
    }
    public static func weekdayFormat(for date: Date) -> String {
        var timeFormat = Date.FormatStyle.dateTime.weekday(.wide)
        timeFormat.timeZone = NSTimeZone.default

        return date.formatted(timeFormat)
    }

    public static func weekdayWithDatesFormat(for date: Date) -> String {
        var timeFormat = Date.FormatStyle.dateTime.weekday(.wide).day().month()
        timeFormat.timeZone = NSTimeZone.default

        return date.formatted(timeFormat)
    }


    public static func timeIntervalFormat(startTime: Date, endTime: Date) -> String {

        var timeFormat = Date.FormatStyle.dateTime.hour().minute()
        timeFormat.timeZone = NSTimeZone.default

        return "\(startTime.formatted(timeFormat)) - \(endTime.formatted(timeFormat))"
    }
    
    public static func dateIntervalFormat(startDate: CalendarDate, endDate: CalendarDate) -> String {
        return " \(startDate.date.formatted(.dateTime.month().day().year())) - \(endDate.date.formatted(.dateTime.month().day().year()))"
    }

    public static func timeOfDayFormat(for date: Date) -> String {

        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.default

        var date = date
        let hour = calendar.component(.hour, from: date)

        let timeOfDay: String

        guard hour >= 0 && hour < 24 else { return "failed to format" }

        if hour < 6 {
            timeOfDay = "Night"
            
            // If we're in the early saturday AM, people feel like it's actually friday night still,
            // so show the date as the day before to reduce confusion (I think, this should probably be tested)
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        } else if hour > 6 && hour < 12 {
            timeOfDay = "Morning"
        } else if hour > 12 &&  hour < 17 {
            timeOfDay = "Afternoon"
        } else if hour > 17 && hour < 20 {
            timeOfDay = "Evening"
        } else {
            timeOfDay = "Night"
        }

        return "\(FestivlFormatting.weekdayFormat(for: date)) \(timeOfDay)"
    }
}



