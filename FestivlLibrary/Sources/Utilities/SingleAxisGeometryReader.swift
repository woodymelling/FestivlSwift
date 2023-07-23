//
//  File.swift
//  
//
//  Created by Woody on 3/7/22.
//

import Foundation
import SwiftUI

public struct SingleAxisGeometryReader<Content: View>: View {
    private struct SizeKey: PreferenceKey {
        static var defaultValue: CGFloat { 10 }
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }

    @State private var size: CGFloat = SizeKey.defaultValue
    var axis: Axis = .horizontal
    var alignment: Alignment = .center
    @ViewBuilder let content: (CGFloat) -> Content

    public init(axis: Axis, alignment: Alignment = .center, @ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.axis = axis
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        content(size)
            .frame(
                maxWidth:  axis == .horizontal ? .infinity : nil,
                maxHeight: axis == .vertical ? .infinity : nil,
                alignment: alignment
            )
            .background(GeometryReader {
                proxy in
                Color.clear.preference(key: SizeKey.self, value: axis == .horizontal ? proxy.size.width : proxy.size.height)
            })
            .onPreferenceChange(SizeKey.self) { size = $0 }
    }
}
