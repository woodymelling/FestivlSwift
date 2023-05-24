//
//  ScheduleHourLinesView.swift
//  
//
//  Created by Woody on 2/17/22.
//

import SwiftUI
import Utilities

private struct DayStartsAtNoonEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var dayStartsAtNoon: Bool {
        get { self[DayStartsAtNoonEnvironmentKey.self] }
        set { self[DayStartsAtNoonEnvironmentKey.self] = newValue }
    }
}

public struct ScheduleHourLabelsView: View {
    public init() {}
    
    @Environment(\.dayStartsAtNoon) var dayStartsAtNoon

    // Cache if expensive

    @ScaledMetric var hourLabelsWidth: CGFloat = 43

    public var body: some View {

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
        .frame(maxWidth: hourLabelsWidth, alignment: .trailing)
    }
    
    func timeStringForIndex(_ index: Int) -> String{
        var index: Int = index
        if dayStartsAtNoon {
            index = (index + 12) % 24
        }
        switch index {
        case 0: return "mdnt"
        case 12: return "noon"
        default:
            
            return Calendar.current.date(from: DateComponents(timeZone: .current, hour: index))!
                .formatted(
                    .dateTime.hour(.defaultDigits(amPM: .abbreviated))
                )
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
        }

    }
}

struct ScheduleHourLinesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScheduleHourLabelsView()
                .environment(\.dayStartsAtNoon, false)
                .previewDisplayName("Day starts at midnight")

            ScheduleHourLabelsView()
                .environment(\.dayStartsAtNoon, true)
                .previewDisplayName("Day starts at noon")
        }
        .previewAllColorModes()

    }
}
