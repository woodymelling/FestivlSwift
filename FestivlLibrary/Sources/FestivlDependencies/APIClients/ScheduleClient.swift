//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/7/22.
//

import Foundation
import IdentifiedCollections
import Models
import XCTestDynamicOverlay
import Dependencies
import Combine

public struct ScheduleClient {
    public init(getSchedule: @escaping () -> DataStream<Schedule>) {
        self.getSchedule = getSchedule
    }
    
    public var getSchedule: () -> DataStream<Schedule>
}

public enum ScheduleClientKey: TestDependencyKey {
    public static var testValue = ScheduleClient(
        getSchedule: XCTUnimplemented("EventClient.getEvents")
    )
    
    public static var previewValue = ScheduleClient(
        getSchedule: { Just(Schedule(scheduleItems: ScheduleItem.previewData(), dayStartsAtNoon: true, timeZone: NSTimeZone.default)).eraseToDataStream() }
    )
}

public extension DependencyValues {
    var scheduleClient: ScheduleClient {
        get { self[ScheduleClientKey.self] }
        set { self[ScheduleClientKey.self] = newValue }
    }
}




