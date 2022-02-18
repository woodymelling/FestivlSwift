//
//  File.swift
//  
//
//  Created by Woody on 2/16/22.
//

import Foundation
import XCTest
import Components

final class TimeOfDayFormattingTests: XCTestCase {
    var calendar = Calendar.current
    func testMorningFormatting() throws {
        // 8 AM
        let morningDate = calendar.date(from: DateComponents(hour: 8))!
        print(morningDate)
        XCTAssertEqual(
            FestivlFormatting.timeOfDayFormat(for: morningDate),
            "Saturday Morning"
        )
    }

    func testAfternoonFormatting() throws {
        // 1 PM
        let afternoonDate = calendar.date(from: DateComponents(day: 2, hour: 13))!
        XCTAssertEqual(
            FestivlFormatting.timeOfDayFormat(for: afternoonDate),
            "Sunday Afternoon"
        )
    }

    func testEveningFormatting() throws {
        // 7 PM
        let eveningDate = calendar.date(from: DateComponents(hour: 19))!
        XCTAssertEqual(
            FestivlFormatting.timeOfDayFormat(for: eveningDate),
            "Saturday Evening"
        )
    }

    func testNightFormatting() throws {
        // 11 PM
        let nightDateBeforeMidnight = calendar.date(from: DateComponents(hour: 23))!
        XCTAssertEqual(
            FestivlFormatting.timeOfDayFormat(for: nightDateBeforeMidnight),
            "Saturday Night"
        )

        // 12 PM Friday Night
        let nightDateMidnight = calendar.date(from: DateComponents(hour: 0))!
        XCTAssertEqual(
            FestivlFormatting.timeOfDayFormat(for: nightDateMidnight),
            "Friday Night"
        )

        // 4AM Saturday Morning (AKA friday night)
        let nightDateAfterMidnight = calendar.date(from: DateComponents(hour: 4))!
        XCTAssertEqual(
            FestivlFormatting.timeOfDayFormat(for: nightDateAfterMidnight),
            "Friday Night"
        )
    }
}

