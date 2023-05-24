//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/21/22.
//

import SwiftUI
import Utilities
import Combine
import Models

public struct SelectingScrollView<Content: View, Tag: Hashable>: View {
    var content: () -> Content
    var tag: Tag?

    public init(selecting tag: Tag?, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.tag = tag
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                content()
                    .onChange(of: tag) { newTag in
                        if let newTag {
                            withAnimation {
                                proxy.scrollTo(newTag, anchor: .center)
                            }
                        }
                    }
            }
        }
    }
}


