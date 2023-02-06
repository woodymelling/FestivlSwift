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
    public init(getSchedule: @escaping (Event.ID) -> DataStream<Schedule>) {
        self.getSchedule = getSchedule
    }
    
    public var getSchedule: (Event.ID) -> DataStream<Schedule>
}

public enum ScheduleClientKey: TestDependencyKey {
    public static var testValue = ScheduleClient(
        getSchedule: XCTUnimplemented("EventClient.getEvents")
    )
    
    public static var previewValue = ScheduleClient(
        getSchedule: { _ in Just(Schedule(scheduleItems: ScheduleItem.testValues(), dayStartsAtNoon: true)).eraseToDataStream() }
    )
}

public extension DependencyValues {
    var scheduleClient: ScheduleClient {
        get { self[ScheduleClientKey.self] }
        set { self[ScheduleClientKey.self] = newValue }
    }
}




