//
//  File.swift
//  
//
//  Created by Woodrow Melling on 9/29/22.
//

import Foundation
import Utilities

public enum StoredEventID {
    @Storage(key: "savedEventID", defaultValue: nil)
    public static var savedEventID: String?
}
