//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 4/13/22.
//

import SwiftUI
import Utilities

struct DropAnimationViewModifier: ViewModifier {
    init(shouldAnimate: Bool) {
        self.shouldAnimate = shouldAnimate
    }

    var shouldAnimate: Bool

    @State var time: CGFloat = 0


    func height(scaled range: ClosedRange<CGFloat> = 0...1) -> CGFloat {
        time
            .scaled(0...2)
            .floor(at: 1)
            .unitInverted
            .scaled(range)
    }



    func body(content: Content) -> some View {
        if shouldAnimate {
            content
                .zIndex(.greatestFiniteMagnitude)

                .shadow(color: .black, radius: height(scaled: 0...4), x: 0, y: height(scaled: 0...2))
                .border(.white.opacity(time.scaled(-2...1)))

                .scaleEffect(height(scaled: 1.0...1.005))
                .onAppear {
                    time = 0
                    withAnimation(.easeIn) {
                        time = 1
                    }
                }



        } else {
            content
                .clipped()
        }

    }
}

extension View {
    func dropAnimation(shouldAnimate: Bool) -> some View {
        self.modifier(DropAnimationViewModifier(shouldAnimate: shouldAnimate))
    }
}

private extension CGFloat {
    var unitInverted: CGFloat {
        -self + 1
    }

    func scaled(_ range: ClosedRange<CGFloat>) -> CGFloat {
        let size = range.upperBound - range.lowerBound

        return self * size + range.lowerBound
    }
}
