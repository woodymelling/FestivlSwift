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
        public static var website = Image(systemName: "website")
    }
}
