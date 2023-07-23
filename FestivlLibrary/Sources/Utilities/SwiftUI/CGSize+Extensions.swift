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
        return CGSize(
            width: width.floor(at: floor.width),
            height: height.floor(at: floor.height)
        )
    }

    func ceiling(at ceiling: CGSize) -> CGSize {
        CGSize(
            width: width.ceiling(at: ceiling.width),
            height: height.ceiling(at: ceiling.height)
        )
    }

    func bounded(min: Self, max: Self) -> Self {
        self.ceiling(at: max).floor(at: min)
    }

    var maxSideLength: CGFloat {
        return max(width, height)
    }

    var minSideLength: CGFloat {
        return min(width, height)
    }

    static func + (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(
            width: left.width + right.width,
            height: left.height + right.height
        )
    }

    static func - (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(
            width: left.width - right.width,
            height: left.height - right.height
        )
    }

    static func / (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(
            width: left.width / right,
            height: left.height / right
        )
    }

    static func * (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(
            width: left.width * right,
            height: left.height * right
        )
    }
}

prefix operator -
prefix func - (_ value: CGSize) -> CGSize {
    return .zero - value
}
