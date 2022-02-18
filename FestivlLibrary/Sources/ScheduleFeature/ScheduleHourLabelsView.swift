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
            return Calendar.current.date(from: DateComponents(hour: index))!
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
                }
            }
            .offset(y: -hourSpacing / 2 - 2) // Make it match the lines

        }
        .frame(maxWidth: 43 * size, alignment: .trailing)


    }
}

struct ScheduleHourLinesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScheduleHourLabelsView(dayStartsAtNoon: false)
                .previewDisplayName("Day starts at midnight")

            ScheduleHourLabelsView(dayStartsAtNoon: true)
                .previewDisplayName("Day starts at noon")
        }
        .previewAllColorModes()

    }
}
