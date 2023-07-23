//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/22/22.
//

import Foundation
import SwiftUI

public enum SharedResources {
    public enum LinkIcons {
        public static var spotify = Image("spotify", bundle: .module)
        public static var soundcloud = Image("soundcloud", bundle: .module)
        public static var website = Image(systemName: "globe")
        public static var instagram = Image("instagram", bundle: .module)
        public static var facebook = Image("facebook", bundle: .module)
        public static var youtube = Image("youtube", bundle: .module)
    }
}
