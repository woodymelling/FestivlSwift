//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/28/23.
//

import Foundation

public protocol TimeRangeRepresentable { // TODO: Replace All Range<Date> with DateInterval
    var timeRange: Range<Date> { get }
}

public protocol TimelineCard: Equatable, Identifiable {
    var dateRange: Range<Date> { get }
    var groupWidth: Range<Int> { get }
}

extension Collection {
    public func sorted<T, U>(by keyPath: KeyPath<Element, T>, and secondaryKeyPath: KeyPath<Element, U>) -> [Element] where T : Comparable, U: Comparable {
        self.sorted {
            if $0[keyPath: keyPath] == $1[keyPath: keyPath] {
                return $0[keyPath: secondaryKeyPath] < $1[keyPath: secondaryKeyPath]
            } else {
                return $0[keyPath: keyPath] < $1[keyPath: keyPath]
            }
        }
    }
}

public struct TimelineWrapper<Value: Identifiable & Equatable & TimeRangeRepresentable>: TimelineCard, Equatable, Identifiable {
    public var groupWidth: Range<Int>
    public var item: Value
    
    public init(groupWidth: Range<Int>, item: Value) {
        self.groupWidth = groupWidth
        self.item = item
    }
    
    public var id: Value.ID { item.id }
    public var dateRange: Range<Date> { item.timeRange }
}

extension Collection where Element: TimeRangeRepresentable & Equatable & Identifiable {
    public var groupedToPreventOverlaps: [TimelineWrapper<Element>] {
        var columns: [[Element]] = [[]]
        
        let sortedItems = self.sorted(
            by: \.timeRange.lowerBound,
            and: \.timeRange.upperBound
        )
        
        for item in sortedItems {
            for (idx, column) in columns.enumerated() {
                // Has overlap
                if let lastItem = column.last, item.timeRange.overlaps(lastItem.timeRange) {
                    if !columns.indices.contains(idx + 1) {
                        columns.append([item])
                    }
                    
                    continue
                } else {
                    columns[idx].append(item)
                    break
                }
            }
        }
        
        var output: [TimelineWrapper<Element>] = []
        
        for (columnIdx, column) in columns.enumerated() {
            
            for item in column {
                var endColumn = columnIdx
                for columnIdx in (columnIdx)..<columns.count {
                    if !columns[columnIdx].contains(where: {
                        item.timeRange.overlaps($0.timeRange)
                    }) {
                        endColumn = columnIdx
                    }
                }
                
                
                output.append(TimelineWrapper(groupWidth: columnIdx..<endColumn, item: item))
            }
        }

        return output
    }
}
