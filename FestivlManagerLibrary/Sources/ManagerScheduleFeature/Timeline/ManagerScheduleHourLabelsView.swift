//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/29/22.
//

import Foundation
import SwiftUI

struct ScheduleHourLabelsView: View {

    var dayStartsAtNoon: Bool

    // Cache if expensive
    func timeStringForIndex(_ index: Int) -> String{
        var index: Int = index
        if dayStartsAtNoon {
            index = (index + 12) % 24
        }
        switch index {
        case 0:
            return "mdnt"
        case 12:
            return "noon"
        default:
            
//            var calendar = Calendar.autoupdatingCurrent
//            calendar.timeZone = NSTimeZone.default
            return Calendar.current.date(from: DateComponents(timeZone: NSTimeZone.system, hour: index))!
                .formatted(
                    .dateTime.hour(.defaultDigits(amPM: .abbreviated))
                )
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
        }

    }
    

    var body: some View {
        GeometryReader { geo in
            let hourSpacing = geo.size.height / 24

            ForEach(0..<24) { index in

                let lineHeight = hourSpacing * CGFloat(index)

                Text(timeStringForIndex(index))
                    .font(.caption)
                    .foregroundColor(gridColor)
                    .position(y: lineHeight)
                    .padding(.leading)
            }
        }

    }
}
