//
//  File.swift
//  
//
//  Created by Woody on 2/16/22.
//

import Foundation
import SwiftUI

public extension CGSize {
    static func square(_ size: CGFloat) -> CGSize {
        return CGSize(width: size, height: size)
    }

    func floor(at floor: CGSize) -> CGSize {
        var newWidth: CGFloat
        var newHeight: CGFloat

        newWidth = self.width < floor.width ? floor.width : self.width
        newHeight = self.height < floor.height ? floor.height : self.height

        return CGSize(width: newWidth, height: newHeight)
    }

    func ceiling(at ceiling: CGSize) -> CGSize {
        var newWidth: CGFloat
        var newHeight: CGFloat

        newWidth = self.width > ceiling.width ? ceiling.width : self.width
        newHeight = self.height > ceiling.height ? ceiling.height : self.height

        return CGSize(width: newWidth, height: newHeight)
    }

    func bounded(min: Self, max: Self) -> Self {
        return self.ceiling(at: max).floor(at: min)
    }

    var maxSideLength: CGFloat {
        return max(width, height)
    }

    var minSideLength: CGFloat {
        return min(width, height)
    }

    static func + (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }

    static func - (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width - right.width, height: left.height - right.height)
    }

    static func / (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width / right, height: left.height / right)
    }

    static func * (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width * right, height: left.height * right)
    }
}
