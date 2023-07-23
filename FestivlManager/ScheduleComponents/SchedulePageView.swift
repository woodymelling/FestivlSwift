//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/23/23.
//

import Foundation
import SwiftUI

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
    }
    
    public var body: some View {
        ScheduleGrid {
            GeometryReader { geo in
                ForEach(cards) { scheduleItem in
                    cardContent(scheduleItem)
                        .id(scheduleItem.id)
                        .zIndex(0)
                        .placement(frame(for: scheduleItem, in: geo.size))
                }
            }
            .frame(height: 1500)
            .id(UUID()) // TODO: Hacky thing to prevent stage paging issues
        }
    }
    
    func frame(for timelineCard: ListType.Element, in size: CGSize) -> CGRect {
        let frame = timelineCard.frame(in: size, groupMapping: self.groupMapping, dayStartsAtNoon: self.dayStartsAtNoon)
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
        return containerWidth / CGFloat(groupMapping.count) * CGFloat(groupMapping[groupWidth.lowerBound] ?? 0)
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

public extension Date {
    func toY(containerHeight: CGFloat, dayStartsAtNoon: Bool) -> CGFloat {

        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = NSTimeZone.default
        

        var hoursIntoTheDay = calendar.component(.hour, from: self)
        let minutesIntoTheHour = calendar.component(.minute, from: self)

        if dayStartsAtNoon {
            // Shift the hour start by 12 hours, we're doing nights, not days
            hoursIntoTheDay = (hoursIntoTheDay + 12) % 24
        }

        let hourInSeconds = hoursIntoTheDay * 60 * 60
        let minuteInSeconds = minutesIntoTheHour * 60

        return secondsToY(hourInSeconds + minuteInSeconds, containerHeight: containerHeight)
    }
}

/// Get the y placement for a specific numbers of seconds
public func secondsToY(_ seconds: Int, containerHeight: CGFloat) -> CGFloat {
    let dayInSeconds: CGFloat = 86400
    let progress = CGFloat(seconds) / dayInSeconds
    return containerHeight * progress
}


//extension View {
//    func placement(_ frame: CGRect) -> some View {
//        self
//            .frame(width: frame.width, height: frame.height)
//            .position(frame.offsetBy(dx: frame.size.width / 2, dy: frame.size.height / 2).origin)
//    }
//}


extension Range where Bound == Date {
    var lengthInSeconds: Double {
        return upperBound.timeIntervalSince(lowerBound)
    }
}
