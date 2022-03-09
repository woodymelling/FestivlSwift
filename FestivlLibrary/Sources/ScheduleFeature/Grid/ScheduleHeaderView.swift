//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/17/22.
//

import SwiftUI
import IdentifiedCollections
import Models
import Components

struct ScheduleHeaderView: View {
    var stages: IdentifiedArrayOf<Stage>
    @Binding var selectedStage: Stage
    var body: some View {
        HStack {

            ForEach(stages) { stage in
                Spacer()
                ScheduleHeaderButton(
                    stage: stage,
                    isSelected: selectedStage == stage,
                    onSelect: {
                        selectedStage = $0
                    }
                )
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct ScheduleHeaderButton: View {
    var stage: Stage
    var isSelected: Bool
    @State var press = false
    var onSelect: (Stage) -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text(stage.symbol)
            .font(.largeTitle)
            .padding(20)
            .background {
                if isSelected {
                    Circle()
                        .fill(stage.color)
                }
            }
            .scaleEffect(press ? 0.8 : 1)
            .pressAndReleaseAction(
                pressing: $press,
                animation: .easeInOut(duration: 0.05),
                onRelease: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onSelect(stage)

                }
            )
    }
}

struct ScheduleHeaderView_Previews: PreviewProvider {

    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {

        @State var selectedStage = Stage.testValues[1]
        var body: some View {
            ScheduleHeaderView(
                stages: IdentifiedArray(uniqueElements: Stage.testValues),
                selectedStage: $selectedStage
            )
            .previewLayout(.sizeThatFits)
            .previewAllColorModes()
        }
    }
}

struct PressAndReleaseModifier: ViewModifier {
    @Binding var pressing: Bool
    var animation: Animation? = nil
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged{ state in

                        if let animation = animation {
                            withAnimation(animation) {
                                pressing = true
                            }
                        } else {
                            pressing = true
                        }
                    }
                    .onEnded{ _ in
                        pressing = false
                        onRelease()
                    }
            )
    }
}

extension View {
    func pressAndReleaseAction(pressing: Binding<Bool>, animation: Animation? = nil, onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressAndReleaseModifier(pressing: pressing, animation: animation, onRelease: onRelease))
    }
}
