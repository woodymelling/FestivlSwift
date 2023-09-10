//
//  CachedAsyncIcon.swift
//  
//
//  Created by Woodrow Melling on 8/19/23.
//

import Foundation
import SwiftUI
import Kingfisher
import CachedAsyncImage

public struct CachedAsyncIcon<Content: View>: View {
    public init(
        url: URL?,
        contentMode: SwiftUI.ContentMode = .fill,
        @ViewBuilder placeholder: @escaping () -> Content
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }


    var url: URL?
    var contentMode: SwiftUI.ContentMode
    @ViewBuilder var placeholder: () -> Content

    @State var hasTransparency = false

    public var body: some View {
        GeometryReader { _ in
            CachedAsyncImage(url: url, urlCache: .iconCache) { image in
                image
                    .resizable()
                    .renderingMode(hasTransparency ? .template : .original)
                    .task {
                        self.hasTransparency = await image.frame(square: 100).hasTransparency()
                    }
            } placeholder: {
                placeholder()
            }
        }
    }
}


public struct ContentAwareTemplateImage: View {
    var image: Image

    public init(image: Image) {
        self.image = image
    }

    @State var hasTransparency: Bool = false

    public var body: some View {
        image
            .renderingMode(hasTransparency ? .template : .original)
            .task {
                self.hasTransparency = await image.frame(square: 100).hasTransparency()
            }
            .onChange(of: image) { image in
                Task {
                    self.hasTransparency = await image.frame(square: 100).hasTransparency()
                }
            }
    }
}


protocol ImageModifier {
    /// `Body` is derived from `View`
    associatedtype Body : View

    /// Modify an image by applying any modifications into `some View`
    func body(image: Image) -> Self.Body
}

extension Image {
    func modifier<M>(_ modifier: M) -> some View where M: ImageModifier {
        modifier.body(image: self)
    }
}

extension URLCache {

    static let iconCache = URLCache(memoryCapacity: 512_000_000, diskCapacity: 10_000_000_000)
}


extension View {
    func task(_ task: @escaping (Self) async -> Void) -> some View {
        self.task {
            await task(self)
        }
    }
}
