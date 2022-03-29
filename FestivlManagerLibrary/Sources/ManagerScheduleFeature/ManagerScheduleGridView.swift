//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/29/22.
//

import Foundation
import SwiftUI

struct GridView: View {

    var timelineHeight: CGFloat
    let stageCount: Int

    var body: some View {
        GeometryReader { geo in
            let hourSpacing = geo.size.height / 24
            let stageSpacing = (geo.size.width) / CGFloat(stageCount)


            ZStack {
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
                                    x: geo.size.width,
                                    y: lineHeight
                                )
                            )
                        }
                        .stroke(gridColor)
                    }
                }

                ForEach(0..<stageCount, id: \.self) { index in

                    let columnWidth = stageSpacing * CGFloat(index)

                    if index > 0 {
                        Path { path in
                            path.move(
                                to: CGPoint(
                                    x: columnWidth,
                                    y: 0
                                )
                            )

                            path.addLine(
                                to: CGPoint(
                                    x: columnWidth,
                                    y: geo.size.height
                                )
                            )
                        }
                        .stroke(gridColor)
                    }
                }
            }
        }
        .frame(height: timelineHeight)
    }
}
