//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation
import Firebase

public enum FirebaseServices {
    public static func initialize(enablePersistance: Bool = true) {
        FirebaseApp.configure()
        Firestore.firestore().settings.cacheSettings = PersistentCacheSettings()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
    }
}
