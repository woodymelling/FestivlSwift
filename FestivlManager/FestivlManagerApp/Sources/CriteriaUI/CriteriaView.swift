//
//  File.swift
//  
//
//  Created by Woodrow Melling on 8/19/23.
//

import Foundation
import SwiftUI
import Utilities

public struct CriteriaView<T: Equatable>: View {
    var value: Loader<T>?
    var criteria: [LabeledPredicate<T>]

    public init(
        for value: Loader<T>? = nil,
        @ArrayBuilder<LabeledPredicate<T>> criteria: () -> [LabeledPredicate<T>]
    ) {
        self.value = value
        self.criteria = criteria()
    }

    @State var isFullyCorrect: Bool = false

    @Environment(\.successAnimationDuration) var successAnimationDuration

    public var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array(zip(criteria.indices, criteria)), id: \.0) { idx, criterion in

                let value = try? value?.map(criterion.evaluate(_:))

                HStack {
                    LoadableStatusIndicator(value)

                    Text(criterion.label)
                }
                .animation(
                    .easeIn(duration: successAnimationDuration.seconds)
                        .delay(Double(idx) * successAnimationDuration.seconds),
                    value: value,
                    when: isFullyCorrect
                )
            }
        }
        .onChange(of: value) { oldValue, value in
            self.isFullyCorrect = criteria.allSatisfy { criteria in
                if let value = value?.loaded {
                    return (try? criteria.evaluate(value)) ?? false
                } else {
                    return true
                }
            }

            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()

            if self.isFullyCorrect {
                Task {
                    for _ in criteria {
                        feedbackGenerator.impactOccurred()
                        try? await Task.sleep(for: self.successAnimationDuration)
                    }
                }
            }
        }
    }
}

struct SuccessAnimationDurationEnvironmentKey: EnvironmentKey {
    static var defaultValue: Duration = .seconds(0.02)
}

extension EnvironmentValues {
    public var successAnimationDuration: Duration {
        get { self[SuccessAnimationDurationEnvironmentKey.self] }
        set { self[SuccessAnimationDurationEnvironmentKey.self] = newValue }
    }
}
