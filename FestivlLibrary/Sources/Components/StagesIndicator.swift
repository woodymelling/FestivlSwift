//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/14/22.
//

import SwiftUI
import Models

public struct StagesIndicatorView: View {
    public init(stages: [Stage]) {
        self.stages = Array(Set(stages)).sorted(by: { $0.sortIndex > $1.sortIndex })
    }
    
    var stages: [Stage]

    var angleHeight: CGFloat = 5 / 2

    public var body: some View {
        Canvas { context, size in
            let segmentHeight = size.height / CGFloat(stages.count)
            for (index, stage) in stages.enumerated() {
                let index = CGFloat(index)

                context.fill(
                    Path { path in
                        let topLeft = CGPoint(
                            x: 0,
                            y: index * segmentHeight - angleHeight
                        )

                        let topRight = CGPoint(
                            x: size.width,
                            y: index > 0 ?
                                index * segmentHeight + angleHeight :
                                index * segmentHeight
                        )

                        let bottomLeft = CGPoint(
                            x: 0,
                            y: index == stages.indices.last.flatMap { CGFloat($0) } ?
                                index * segmentHeight + segmentHeight :
                                index * segmentHeight + segmentHeight - angleHeight
                        )

                        let bottomRight = CGPoint(
                            x: size.width,
                            y: index * segmentHeight + segmentHeight + angleHeight
                        )

                        path.move(to: topLeft)
                        path.addLine(to: topRight)
                        path.addLine(to: bottomRight)
                        path.addLine(to: bottomLeft)
                    },
                    with: .color(Color(hex: stage.colorString))
                )
            }
        }
    }
}

struct StagesIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StagesIndicatorView(stages: Stage.testValues)
            StagesIndicatorView(stages: [.testData])
        }
        .frame(width: 5, height: 60)
        .previewLayout(.sizeThatFits)


    }
}
