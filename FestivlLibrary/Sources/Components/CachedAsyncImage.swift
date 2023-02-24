//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/12/22.
//

import SwiftUI
import Kingfisher

public struct CachedAsyncImage<Content: View>: View {
    public init(
        url: URL?,
        renderingMode: Image.TemplateRenderingMode = .original,
        contentMode: SwiftUI.ContentMode = .fill,
        @ViewBuilder placeholder: @escaping () -> Content
    ) {
        self.url = url
        self.renderingMode = renderingMode
        self.contentMode = contentMode
        self.placeholder = placeholder
    }


    var url: URL?
    var renderingMode: Image.TemplateRenderingMode
    var contentMode: SwiftUI.ContentMode
    @ViewBuilder var placeholder: () -> Content

    public var body: some View {
        GeometryReader { geo in
            KFImage(url)
                .resizable()
                .renderingMode(renderingMode)
                .placeholder {
                    placeholder()
                }
                .setProcessor(DownsamplingImageProcessor(size: geo.size))
                #if os(iOS)
                .scaleFactor(UIScreen.main.scale)
                #endif
                .aspectRatio(contentMode: contentMode)
        }

    }
}

public struct ImageCacher {
    public static func preFetchImage(urls: [URL]) async {

        return await withUnsafeContinuation { continuation in
            let prefetcher = ImagePrefetcher(urls: urls) {
                skippedResources, failedResources, completedResources in
                print("These resources are prefetched: \(completedResources)")
                print("These resource are skipped: \(skippedResources)")
                continuation.resume()
            }
            prefetcher.start()
        }


    }
}
