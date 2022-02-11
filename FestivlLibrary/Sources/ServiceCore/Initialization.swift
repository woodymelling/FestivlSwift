//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation
import Firebase

public enum FirebaseServices {
    public static func initialize() {
        FirebaseApp.configure()
    }
}
