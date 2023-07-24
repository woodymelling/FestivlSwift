//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/24/23.
//

import Foundation

public extension DateInterval {
    func intersects(_ other: DateInterval, adjacentIntersects: Bool) -> Bool {
        if adjacentIntersects {
            self.intersects(other)
        } else {
            if self.intersects(other) && start == other.end || end == other.start {
                false
            } else {
                self.intersects(other)
            }
        }
        
    }
}
