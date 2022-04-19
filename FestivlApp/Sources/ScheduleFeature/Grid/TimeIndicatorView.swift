//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 4/18/22.
//

import SwiftUI

struct TimeIndicatorView: View {
    var currentTime: Date

    @ScaledMetric var textWidth: CGFloat = 50
    var body: some View {
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
    }
}

struct TimeIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        TimeIndicatorView(currentTime: Date())
    }
}
