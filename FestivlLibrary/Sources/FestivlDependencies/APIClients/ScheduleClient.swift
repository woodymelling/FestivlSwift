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
import DependenciesMacros
import Combine

@DependencyClient
public struct ScheduleClient {
    public var getSchedule: () -> DataStream<Schedule> = { Empty().eraseToDataStream() }
}

extension ScheduleClient: TestDependencyKey {
    public static var testValue: ScheduleClient = Self()

    public static var previewValue = ScheduleClient(
        getSchedule: { Just(Schedule(scheduleItems: ScheduleItem.previewData(), dayStartsAtNoon: true, timeZone: NSTimeZone.default)).eraseToDataStream() }
    )
}

public extension DependencyValues {
    var scheduleClient: ScheduleClient {
        get { self[ScheduleClient.self] }
        set { self[ScheduleClient.self] = newValue }
    }
}




