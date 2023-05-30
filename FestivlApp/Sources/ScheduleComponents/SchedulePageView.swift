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
    var groupCount: Int
    
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
        
        self.groupCount = groups.count
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
        timelineCard.frame(in: size, groupCount: self.groupCount, dayStartsAtNoon: self.dayStartsAtNoon)
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
    func xOrigin(containerWidth: CGFloat, groupCount: Int) -> CGFloat {
        guard groupCount > 1 else { return 0 }
        return containerWidth / CGFloat(groupCount) * CGFloat(groupWidth.lowerBound)
    }
    
    /// Get the y placement for a set in a container of a specific height
    func yOrigin(containerHeight: CGFloat, dayStartsAtNoon: Bool) -> CGFloat {
        return dateRange.lowerBound.toY(containerHeight: containerHeight, dayStartsAtNoon: dayStartsAtNoon)
    }
    /// Get the frame size for an artistSet in a specfic container
    func size(in containerSize: CGSize, groupCount: Int) -> CGSize {
        let setLengthInSeconds = dateRange.lengthInSeconds
        let height = secondsToY(Int(setLengthInSeconds), containerHeight: containerSize.height)
        
        
        let width: CGFloat
        if groupCount <= 1 {
            width = containerSize.width / CGFloat(groupCount)
        } else {
            let groupSpanCount: Int
            groupSpanCount = groupWidth.upperBound - groupWidth.lowerBound + 1
            width = (containerSize.width / CGFloat(groupCount)) * CGFloat(groupSpanCount)
        }

        return CGSize(width: width, height: height)
    }
    
    func frame(in containerSize: CGSize, groupCount: Int, dayStartsAtNoon: Bool) -> CGRect {
        return CGRect(
            origin: CGPoint(
                x: xOrigin(containerWidth: containerSize.width, groupCount: groupCount),
                y: yOrigin(containerHeight: containerSize.height, dayStartsAtNoon: dayStartsAtNoon)
            ),
            size: size(in: containerSize, groupCount: groupCount))
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
