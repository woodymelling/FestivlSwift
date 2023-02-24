//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/17/22.
//

import SwiftUI
import Utilities

struct ScheduleGridView: View {
    var body: some View {
        GeometryReader { proxy in
            let hourSpacing = proxy.size.height / 24

            ForEach(0..<24) { index in

                let lineHeight = hourSpacing * CGFloat(index)

                ZStack {
                    Path { path in
                        path.move(
                            to: CGPoint(
                                x: 0,
                                y: lineHeight
                            )
                        )

                        path.addLine(
                            to: CGPoint(
                                x: 10000,
                                y: lineHeight
                            )
                        )
                    }
                    .stroke(.tertiary)
                }
            }
        }
        
    }
}

struct ScheduleGridView_Previews: PreviewProvider {
    static var previews: some View {
        
        ScheduleGridView()
            .previewAllColorModes()
    }
}
