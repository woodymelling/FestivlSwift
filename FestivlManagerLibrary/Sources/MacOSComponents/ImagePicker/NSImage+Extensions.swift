//
//  NSImage+Extensions.swift
//  FestivlManagerMacOS
//
//  Created by Woody on 8/30/21.
//

import Foundation
import SwiftUI

extension NSImage {
    func trim(rect: CGRect) -> NSImage {
        let result = NSImage(size: rect.size)
        result.lockFocus()

        let destRect = CGRect(origin: .zero, size: result.size)
        draw(in: destRect, from: rect, operation: .copy, fraction: 1.0)

        result.unlockFocus()
        return result
    }

    func resized(to: CGSize) -> NSImage {
        let img = NSImage(size: to)

        img.lockFocus()
        defer {
            img.unlockFocus()
        }

        if let ctx = NSGraphicsContext.current {
            ctx.imageInterpolation = .high
            draw(in: NSRect(origin: .zero, size: to),
                 from: NSRect(origin: .zero, size: size),
                 operation: .copy,
                 fraction: 1)
        }

        return img
    }

    var pngData: Data {
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])!
        return jpegData
    }

}
