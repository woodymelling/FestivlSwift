//
//  ContentAwareTemplateRendering.swift
//  
//
//  Created by Woodrow Melling on 8/19/23.
//

import Foundation

//
//
//struct ContentAwareTemplateRenderingViewModifier: View {
//    
//}

import SwiftUI
//
//
//@MainActor
//extension Image.TemplateRenderingMode {
//    func contentAware(for image: Image) -> Self {
//        let renderer = ImageRenderer(content: image)
//        if let image = renderer.cgImage {
//            let info = image.alphaInfo
//            switch alphaInfo {
//                case .none, .noneSkipLast, .noneSkipFirst:
//                return .original
//                default:
//                return .template
//                }
//        }
//    }
//}


//extension View {
//    @MainActor
//    public var hasAlpha: Bool {
//        reducePixels(false) { $0 || $1.hasTransparency }
//    }
//}

@MainActor
extension View {
    public var cgImage: CGImage? {
        ImageRenderer(content: self).cgImage
    }

    public var uiImage: UIImage? {
        ImageRenderer(content: self).uiImage
    }
}

extension View {
    public func reducePixels<Result>(
        _ initialResult: Result,
        _ nextPartialResult: (Result, PixelData) throws -> Result
    ) async rethrows -> Result {

        guard let cgImage = await self.cgImage
        else { return initialResult }

        return try cgImage.reducePixels(initialResult, nextPartialResult)
    }

    public func hasTransparency() async -> Bool {
        await self.reducePixels(false) { $0 || $1.hasTransparency }
    }
}

extension CGImage {
    public func reducePixels<Result>(
        _ initialResult: Result,
        _ nextPartialResult: (Result, PixelData) throws -> Result
    ) rethrows -> Result {

        guard let pixelData = self.dataProvider?.data
        else { return initialResult }

        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        var pixels: [PixelData] = []

        let width = self.width
        for x in 0..<width {
            for y in 0..<self.height {
                let pixelIndex = ((width * y) + x) * 4

                pixels.append(
                    PixelData(
                        a: data[pixelIndex + 3],
                        r: data[pixelIndex],
                        g: data[pixelIndex + 1],
                        b: data[pixelIndex + 2]
                    )
                )
            }
        }

        return try pixels.reduce(initialResult, nextPartialResult)
    }

    public func hasTransparency() -> Bool {
        self.reducePixels(false) { $0 || $1.hasTransparency }
    }
}


public struct PixelData {
    public var a: UInt8
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8

    public var hasTransparency: Bool {
        a < 255
    }

    public func equalsIgnoringAlpha(with other: PixelData) -> Bool {
        self.r == other.r && self.b == other.b && self.g == other.g
    }

    public var isGrayscale: Bool {
        r == g && g == b
    }

    public var isFullyTransparent: Bool {
        a == 0
    }
}


//
//#Preview {
//    VStack {
//        TestingView {
//            Image(systemName: "star")
//        }
//
//        TestingView {
//            Rectangle()
//                .fill(Color.red)
//                .frame(square: 50)
//        }
//    }
//}
//
//private struct TestingView<Content: View>: View {
//    let view: () -> Content
//
//    var body: some View {
//        HStack {
//            view()
//
//            Text("Has Transparency: \(view().hasAlpha ? "true" : "false")")
//        }
//    }
//}
