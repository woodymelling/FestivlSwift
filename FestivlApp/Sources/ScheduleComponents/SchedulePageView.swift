//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/23/23.
//

import Foundation
import SwiftUI
import Utilities

public struct SchedulePageView<
    ListType: RandomAccessCollection,
    CardContent: View
>: View where ListType.Element: TimelineCard {
    
    @Environment(\.dayStartsAtNoon) var dayStartsAtNoon
    
    var cards: ListType
    var cardContent: (ListType.Element) -> CardContent
    var groups: [Int]
    
    var groupMapping: [Int:Int] = [:]
    
    public init(
        _ cards: ListType,
        @ViewBuilder cardContent: @escaping (ListType.Element) -> CardContent
    ) {
        self.cards = cards
        self.cardContent = cardContent
        
        // Calculate distinct group numbers
        var groups = Set<Int>.init()
        for card in cards {
            groups.insert(card.groupWidth.lowerBound)
        }
        
        self.groups = Array(groups).sorted()
        
        var groupMapping: [Int:Int] = [:]
        for (idx, group) in self.groups.enumerated() {
            groupMapping[group] = idx
        }
        self.groupMapping = groupMapping

        print(groupMapping)
    }
    
    public var body: some View {
        ScheduleGrid {
            GeometryReader { geo in
                ZStack {
                    ForEach(cards) { scheduleItem in
                        cardContent(scheduleItem)
                            .placement(frame(for: scheduleItem, in: geo.size))
                            .id(scheduleItem.id)
                            .zIndex(0)
                    }
                }
            }
            .frame(height: 1500)
        }
    }
    
    func frame(for timelineCard: ListType.Element, in size: CGSize) -> CGRect {
        let frame = timelineCard.frame(in: size, groupMapping: self.groupMapping, dayStartsAtNoon: self.dayStartsAtNoon)
        print(frame)
        return frame
    }
}

extension SchedulePageView {
    public init<T>(
        _ cards: T,
        @ViewBuilder cardContent: @escaping (T.Element) -> CardContent
    )
    where T: RandomAccessCollection,
        ListType == Array<TimelineWrapper<T.Element>>,
        T.Element: TimeRangeRepresentable & Equatable & Identifiable
    {
        self.init(cards.groupedToPreventOverlaps, cardContent: { cardContent($0.item) })
    }
}

extension TimelineCard {
    func xOrigin(containerWidth: CGFloat, groupMapping: [Int:Int]) -> CGFloat {
        guard groupMapping.count > 1 else { return 0 }
git st        return containerWidth / CGFloat(groupMapping.count) * CGFloat(groupMapping[groupWidth.lowerBound] ?? 0)
    }
    
    /// Get the y placement for a set in a container of a specific height
    func yOrigin(containerHeight: CGFloat, dayStartsAtNoon: Bool) -> CGFloat {
        return dateRange.lowerBound.toY(containerHeight: containerHeight, dayStartsAtNoon: dayStartsAtNoon)
    }
    /// Get the frame size for an artistSet in a specfic container
    func size(in containerSize: CGSize, groupMapping: [Int:Int]) -> CGSize {
        let setLengthInSeconds = dateRange.lengthInSeconds
        let height = secondsToY(Int(setLengthInSeconds), containerHeight: containerSize.height)
        
        let width: CGFloat
        if groupMapping.count <= 1 {
            width = containerSize.width / CGFloat(groupMapping.count)
        } else {
            let groupSpanCount: Int
            groupSpanCount = (groupMapping[groupWidth.upperBound] ?? 0) - (groupMapping[groupWidth.lowerBound] ?? 0) + 1
            width = (containerSize.width / CGFloat(groupMapping.count)) * CGFloat(groupSpanCount)
        }

        print(width)
        return CGSize(width: width, height: height)
    }
    
    func frame(in containerSize: CGSize, groupMapping: [Int:Int], dayStartsAtNoon: Bool) -> CGRect {
        return CGRect(
            origin: CGPoint(
                x: xOrigin(containerWidth: containerSize.width, groupMapping: groupMapping),
                y: yOrigin(containerHeight: containerSize.height, dayStartsAtNoon: dayStartsAtNoon)
            ),
            size: size(in: containerSize, groupMapping: groupMapping))
    }
}

extension View {
    func placement(_ frame: CGRect) -> some View {
        self
            .frame(size: frame.size)
            .position(frame.offsetBy(dx: frame.size.width / 2, dy: frame.size.height / 2).origin)
    }
}


extension Range where Bound == Date {
    var lengthInSeconds: Double {
        return upperBound.timeIntervalSince(lowerBound)
    }
}
