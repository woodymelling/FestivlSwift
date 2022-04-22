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

#if os(iOS)

public class StageIndicatorUIView: UIView {
    var stages: [Stage] = []

    let angleHeight: CGFloat = 2.0

    public override init(frame: CGRect) {
        super.init(frame: frame)

        clearsContextBeforeDrawing = true
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setStages(stages: [Stage]) {
        self.stages = stages
        self.setNeedsDisplay()
    }

    func setStage(stage: Stage) {
        self.setStages(stages: [stage])
    }

    public override func draw(_ rect: CGRect) {

        for (i, stage) in stages.enumerated() {
            let width = rect.width
            let height = rect.height / CGFloat(stages.count)
            let startY = height * CGFloat(i)
            let endY = height * CGFloat(i + 1)

            let path = UIBezierPath()

            // Draw top "horizontal" line
            if i == 0 {
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: width, y: 0))
            } else {
                path.move(to: CGPoint(x: 0, y: startY - angleHeight))
                path.addLine(to: CGPoint(x: width, y: startY + angleHeight))
            }

            // Draw bottom
            if i == stages.count - 1 {
                path.addLine(to: CGPoint(x: width, y: rect.height))
                path.addLine(to: CGPoint(x: 0, y: rect.height))
            } else {
                path.addLine(to: CGPoint(x: width, y: endY + angleHeight))
                path.addLine(to: CGPoint(x: 0, y: endY - angleHeight))
            }

            path.close()

            let color = UIColor(stage.color)
            color.set()

            path.fill()
        }
    }

}
#endif

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
