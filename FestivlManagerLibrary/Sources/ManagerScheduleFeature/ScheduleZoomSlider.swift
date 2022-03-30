//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/30/22.
//

import Foundation
import SwiftUI
import MacOSComponents

struct ScheduleZoomSlider: View {
    @Binding var zoomAmount: CGFloat
    var body: some View {
        VStack {
            Text("+")
                VSlider(value: $zoomAmount, in: 0.5...2)
            Text("-")
        }
        .padding(.horizontal)
    }
}
