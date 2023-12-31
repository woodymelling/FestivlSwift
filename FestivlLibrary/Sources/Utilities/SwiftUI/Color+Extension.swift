//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import Foundation
import SwiftUI

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
}

#if os(iOS)
import UIKit

public extension Color {
    var hexString: String {
        UIColor(self).hexString
    }
    
    var isDarkColor: Bool {
        return UIColor(self).isDarkColor
    }
    
    static var label: Color {
        return Color(uiColor: UIColor.label)
    }
    
    static var secondaryLabel: Color {
        return Color(uiColor: UIColor.secondaryLabel)
    }
    
    static var tertiaryLabel: Color {
        return Color(uiColor: UIColor.tertiaryLabel)
    }
    
    static var quaternaryLabel: Color {
        return Color(uiColor: UIColor.quaternaryLabel)
    }
    
    static var systemFill: Color {
        return Color(uiColor: UIColor.systemFill)
    }
    
    static var secondarySystemFill: Color {
        return Color(uiColor: UIColor.secondarySystemFill)
    }
    
    static var tertiarySystemFill: Color {
        return Color(uiColor: UIColor.tertiarySystemFill)
    }
    
    static var quaternarySystemFill: Color {
        return Color(uiColor: UIColor.quaternarySystemFill)
    }
    
    static var systemBackground: Color {
        return Color(uiColor: UIColor.systemBackground)
    }
    
    static var secondarySystemBackground: Color {
        return Color(uiColor: UIColor.secondarySystemBackground)
    }
    
    static var tertiarySystemBackground: Color {
        return Color(uiColor: UIColor.tertiarySystemBackground)
    }
    
    static var systemGroupedBackground: Color {
        return Color(uiColor: UIColor.systemGroupedBackground)
    }
    
    static var secondarySystemGroupedBackground: Color {
        return Color(uiColor: UIColor.secondarySystemGroupedBackground)
    }
    
    static var tertiarySystemGroupedBackground: Color {
        return Color(uiColor: UIColor.tertiarySystemGroupedBackground)
    }
    
    static var systemGray: Color {
        return Color(uiColor: UIColor.systemGray)
    }
    
    static var systemGray2: Color {
        return Color(uiColor: UIColor.systemGray2)
    }
    
    static var systemGray3: Color {
        return Color(uiColor: UIColor.systemGray3)
    }
    
    static var systemGray4: Color {
        return Color(uiColor: UIColor.systemGray4)
    }
    
    static var systemGray5: Color {
        return Color(uiColor: UIColor.systemGray5)
    }
    
    static var systemGray6: Color {
        return Color(uiColor: UIColor.systemGray6)
    }
}

public extension UIColor {
    
    var hexString: String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
    
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50
    }
}
#elseif os(macOS)
public extension Color {
    var hexString: String {
        NSColor(self).hexString
    }
}

public extension NSColor {
    var hexString: String {
        guard let rgbColor = usingColorSpace(.sRGB) else { return "#FFFFFF" }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
        return hexString as String
    }
}
#endif


#if canImport(UIKit)
import UIKit
private typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
private typealias PlatformColor = NSColor
#endif

#if !os(watchOS) // All the methods below are not availalbe for WatchOS at the time of writing

// MARK: - Adaptable colors
// Links to standard colors documentation
// Platform | Reference
// ---------|-----------
// iOS      | https://developer.apple.com/documentation/uikit/uicolor/standard_colors
// OSX      | https://developer.apple.com/documentation/appkit/nscolor/standard_colors
@available(iOS 13.0, macOS 10.15, *)
public extension Color {
    /// A blue color that automatically adapts to the current trait environment.
    static var systemBlue: Color { Color(PlatformColor.systemBlue) }
    /// A brown color that automatically adapts to the current trait environment.
    static var systemBrown: Color { Color(PlatformColor.systemBrown) }
    /// A cyan color that automatically adapts to the current trait environment.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    static var systemCyan: Color { Color(PlatformColor.systemCyan) }
    /// A green color that automatically adapts to the current trait environment.
    static var systemGreen: Color { Color(PlatformColor.systemGreen) }
    /// An indigo color that automatically adapts to the current trait environment.
    static var systemIndigo: Color { Color(PlatformColor.systemIndigo) }
    /// A mint color that automatically adapts to the current trait environment.
    @available(iOS 15.0, macOS 10.15, tvOS 15.0, *)
    static var systemMint: Color { Color(PlatformColor.systemMint) }
    /// An orange color that automatically adapts to the current trait environment.
    static var systemOrange: Color { Color(PlatformColor.systemOrange) }
    /// A pink color that automatically adapts to the current trait environment.
    static var systemPink: Color { Color(PlatformColor.systemPink) }
    /// A purple color that automatically adapts to the current trait environment.
    static var systemPurple: Color { Color(PlatformColor.systemPurple) }
    /// A red color that automatically adapts to the current trait environment.
    static var systemRed: Color { Color(PlatformColor.systemRed) }
    /// A teal color that automatically adapts to the current trait environment.
    static var systemTeal: Color { Color(PlatformColor.systemTeal) }
    /// A yellow color that automatically adapts to the current trait environment.
    static var systemYellow: Color { Color(PlatformColor.systemYellow) }
}
#endif
