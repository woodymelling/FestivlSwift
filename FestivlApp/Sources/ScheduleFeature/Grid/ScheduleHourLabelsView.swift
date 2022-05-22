//
//  ScheduleHourLinesView.swift
//  
//
//  Created by Woody on 2/17/22.
//

import SwiftUI
import Utilities

struct ScheduleHourLabelsView: View {
    var dayStartsAtNoon: Bool
    var currentTime: Date
    var shouldHideTime: Bool

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
            
            return Calendar.current.date(from: DateComponents(timeZone: .current, hour: index))!
                .formatted(
                    .dateTime.hour(.defaultDigits(amPM: .abbreviated))
                )
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
        }

    }

    @ScaledMetric var size: CGFloat = 1

    var body: some View {

        GeometryReader { geo in
            let hourSpacing = geo.size.height / 24

            VStack(alignment: .trailing, spacing: 0) {


                ForEach(0..<24) { index in

                    Text(timeStringForIndex(index))
                        .lineLimit(1)
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                        .frame(height: hourSpacing, alignment: .center)
                        .isHidden(shouldHideTime && shouldHideTimeLabel(for: currentTime, index: index, dayStartsAtNoon: dayStartsAtNoon))
                }
            }
            .offset(y: -hourSpacing / 2 - 2) // Make it match the lines

        }
        .frame(maxWidth: 43 * size, alignment: .trailing)


    }
}


private func shouldHideTimeLabel(for currentTime: Date, index: Int, dayStartsAtNoon: Bool) -> Bool {
    let components = Calendar.current.dateComponents([.hour, .minute], from: currentTime)

    let adjustIndex = dayStartsAtNoon ? (index + 12) % 24 : index
    

    if let hour = components.hour, let minute = components.minute {
        if adjustIndex == hour && minute < 20 {
            return true
        } else if adjustIndex == hour + 1 && minute > 40 {
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}


struct ScheduleHourLinesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScheduleHourLabelsView(dayStartsAtNoon: false, currentTime: Date(), shouldHideTime: true)
                .previewDisplayName("Day starts at midnight")

            ScheduleHourLabelsView(dayStartsAtNoon: true, currentTime: Date(), shouldHideTime: true)
                .previewDisplayName("Day starts at noon")
        }
        .previewAllColorModes()

    }
}
