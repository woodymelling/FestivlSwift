//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 4/18/22.
//

import SwiftUI

struct TimeIndicatorEnvironment: Equatable {
    var currentTime: Date

}


struct TimeIndicatorView: View {
    var selectedDate: Date
    var dayStartsAtNoon: Bool

    func shouldShowTimeIndicator(_ currentTime: Date) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.default
        if dayStartsAtNoon {
            return calendar.isDate(
                currentTime - 12.hours,
                inSameDayAs: selectedDate.startOfDay(dayStartsAtNoon: dayStartsAtNoon)
            )
        } else {
            return calendar.isDate(currentTime, inSameDayAs: selectedDate)
        }
    }

    var timeFormat: Date.FormatStyle {
        var format = Date.FormatStyle.dateTime.hour(.defaultDigits(amPM: .narrow)).minute()
        format.timeZone = NSTimeZone.default
        return format
    }

    @ScaledMetric var textWidth: CGFloat = 50
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            GeometryReader { geo in
                if shouldShowTimeIndicator(context.date) {
                    ZStack(alignment: .leading) {
                        Text(
                            context.date
                                .formatted(
                                    timeFormat
                                )
                                .lowercased()
                                .replacingOccurrences(of: " ", with: "")
                        )
                        .foregroundColor(Color.accentColor)
                        .font(.caption)
                        .frame(width: textWidth)

                        Circle()
                            .fill(Color.accentColor)
                            .frame(square: 5)
                            .offset(x: textWidth, y: 0)

                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(height: 1)
                            .offset(x: textWidth, y: 0)
                    }
                    .position(x: geo.size.width / 2, y: context.date.toY(containerHeight: geo.size.height, dayStartsAtNoon: dayStartsAtNoon))
                } else {
                    EmptyView()
                }
            }
        }

    }
}

struct TimeIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        TimeIndicatorView(selectedDate: Date(), dayStartsAtNoon: false)
    }
}
