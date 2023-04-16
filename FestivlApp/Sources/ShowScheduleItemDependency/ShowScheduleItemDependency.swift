//
//  File.swift
//
//
//  Created by Woodrow Melling on 4/14/23.
//

import Foundation
import Dependencies
import Combine
import Models

public struct ShowScheduleItemClient {
    static var livePublisher: PassthroughSubject<ScheduleItem, Never> = .init()
    
    
    public var showScheduleItem: (ScheduleItem) -> Void
    public var items: () -> AnyPublisher<ScheduleItem, Never>
    
    public func callAsFunction(_ scheduleItem: ScheduleItem) {
        self.showScheduleItem(scheduleItem)
    }
}

public enum ShowScheduleItemClientKey: DependencyKey {
    public static var testValue = ShowScheduleItemClient(
        showScheduleItem: XCTUnimplemented("ShowScheduleItemClient.showScheduleItem"),
        items: unimplemented("ShowScheduleItemClient.items")
    )
    
    public static var liveValue: ShowScheduleItemClient {
        ShowScheduleItemClient(
            showScheduleItem: { ShowScheduleItemClient.livePublisher.send($0) },
            items: { return ShowScheduleItemClient.livePublisher.eraseToAnyPublisher() }
        )
    }
}

public extension DependencyValues {
    var showScheduleItem: ShowScheduleItemClient {
        get { self[ShowScheduleItemClientKey.self] }
        set { self[ShowScheduleItemClientKey.self] = newValue }
    }
}
