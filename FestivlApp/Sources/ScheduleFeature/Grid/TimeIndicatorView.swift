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

    @State var currentTime: Date = Date()

    var shouldShowTimeIndicator: Bool {
        if dayStartsAtNoon {
            return Calendar.current.isDate(
                currentTime - 12.hours,
                inSameDayAs: selectedDate.startOfDay(dayStartsAtNoon: dayStartsAtNoon)
            )
        } else {
            return Calendar.current.isDate(currentTime, inSameDayAs: selectedDate)
        }
    }


    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @ScaledMetric var textWidth: CGFloat = 50
    var body: some View {
        GeometryReader { geo in
            if shouldShowTimeIndicator {
                ZStack(alignment: .leading) {
                    Text(
                        currentTime
                            .formatted(
                                .dateTime
                                .hour(
                                    .defaultDigits(amPM: .narrow)
                                )
                                .minute()
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
                .position(x: geo.size.width / 2, y: currentTime.toY(containerHeight: geo.size.height, dayStartsAtNoon: dayStartsAtNoon))
            } else {
                EmptyView()
            }
        }
        .onReceive(timer, perform: {
            currentTime = $0
        })

    }
}

struct TimeIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        TimeIndicatorView(selectedDate: Date(), dayStartsAtNoon: false)
    }
}
