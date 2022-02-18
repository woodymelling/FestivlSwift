//
//  File.swift
//  
//
//  Created by Woody on 2/16/22.
//

import Foundation

public enum FestivlFormatting {
    public static func timeIntervalFormat(startTime: Date, endTime: Date) -> String {

        let timeFormat = Date.FormatStyle.dateTime.hour().minute()
        return "\(startTime.formatted(timeFormat)) - \(endTime.formatted(timeFormat))"
    }

    public static func timeOfDayFormat(for date: Date) -> String {
        var date = date
        let hour = Calendar.current.component(.hour, from: date)

        let timeOfDay: String

        guard hour >= 0 && hour < 24 else { return "failed to format" }

        if hour < 6 {
            timeOfDay = "Night"
            // If we're in the early saturday AM, people feel like it's actually friday night still,
            // so show the date as the day before to reduce confusion (I think, this should probably be tested)
            date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        } else if hour > 6 && hour < 12 {
            timeOfDay = "Morning"
        } else if hour > 12 &&  hour < 17 {
            timeOfDay = "Afternoon"
        } else if hour > 17 && hour < 20 {
            timeOfDay = "Evening"
        } else {
            timeOfDay = "Night"
        }

        return "\(date.formatted(.dateTime.weekday(.wide))) \(timeOfDay)"
    }
}
