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
import Utilities

struct ScheduleHeaderView: View {
    var stages: IdentifiedArrayOf<Stage>
    @Binding var selectedStage: Stage


    var body: some View {
        ZStack(alignment: .bottom) {




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
                    .shadow()
                }
                Spacer()
            }
            .background(Color(uiColor: .systemBackground))
            .frame(maxWidth: .infinity)
            .shadow()

        }
    }
}

private extension View {
    func shadow() -> some View {
        self.shadow(color: Color(uiColor: .systemBackground), radius: 4, x: 0, y: 0)
    }
}

struct ScheduleHeaderButton: View {
    var stage: Stage
    var isSelected: Bool
    @State var press = false
    var onSelect: (Stage) -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        CachedAsyncImage(url: stage.iconImageURL, renderingMode: .template, placeholder: {
            Text(stage.symbol)
                .font(.largeTitle)
                .padding(20)
        })
        .if(colorScheme == .light, transform: {
            $0.if(isSelected) {
                $0.foregroundColor(.white)
            } else: {
                $0.foregroundColor(stage.color)
            }
        })
        .frame(square: 60)
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
