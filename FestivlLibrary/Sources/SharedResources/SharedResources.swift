//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/22/22.
//

import Foundation
import SwiftUI
import Utilities

public enum FestivlAssets {
    public enum LinkIcons {
        public static var spotify = Image("spotify", bundle: .module)
        public static var soundcloud = Image("soundcloud", bundle: .module)
        public static var website = Image(systemName: "globe")
        public static var instagram = Image("instagram", bundle: .module)
        public static var facebook = Image("facebook", bundle: .module)
        public static var youtube = Image("youtube", bundle: .module)
        public static var googleMaps = Image("google-maps", bundle: .module)
        public static var appleMaps = Image("apple-maps", bundle: .module)
    }
    
    public enum Icons {
        public static var handWithSmartphone = Image("handWithSmartphone", bundle: .module)
        public static var workshops = Image("workshops", bundle: .module)
    }
    
    public enum Colors { // TODO: Make an EnvironmentValue for this stuff.
        public static let customPurple = Color(hex: "#401F34")
        public static let customRed = Color(hex: "#A62428")
        public static let customOrange = Color(hex: "#DE5F29")
        public static let customBlue = Color(hex: "#143144")
        public static let customGreen = Color(hex: "#324A33")
        public static let customLightBlue = Color(hex: "#4b9ed5")
    }
}
