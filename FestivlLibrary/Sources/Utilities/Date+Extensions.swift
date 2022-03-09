//
//  File.swift
//  
//
//  Created by Woody on 2/20/22.
//

import Foundation

public extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
