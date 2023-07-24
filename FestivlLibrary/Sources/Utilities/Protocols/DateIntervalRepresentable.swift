//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/24/23.
//

import Foundation

public protocol DateIntervalRepresentable { // TODO: Replace All Range<Date> with DateInterval
    var dateInterval: DateInterval { get }
}
