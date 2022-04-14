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
        @ViewBuilder placeholder: @escaping () -> Content
    ) {
        self.url = url
        self.renderingMode = renderingMode
        self.placeholder = placeholder
    }


    var url: URL?
    var renderingMode: Image.TemplateRenderingMode
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
                .cacheOriginalImage()
                #if os(iOS)
                .scaleFactor(UIScreen.main.scale)
                #endif
                .aspectRatio(contentMode: .fill)
        }

    }
}

public struct ImageCacher {
    public static func preFetchImage(urls: [URL]) async {

        return await withUnsafeContinuation { continuation in
            let prefetcher = ImagePrefetcher(urls: urls) {
                skippedResources, failedResources, completedResources in
                print("These resources are prefetched: \(completedResources)")
                continuation.resume()
            }
            prefetcher.start()
        }


    }
}
