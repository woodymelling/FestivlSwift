//
//  ScheduleManagementTests.swift
//  
//
//  Created by Woodrow Melling on 7/11/23.
//

import XCTest
import ComposableArchitecture
@testable import ScheduleManagementFeature
@testable import Models
@testable import FestivlDependencies
@testable import Utilities

@MainActor
final class ScheduleManagementTests: XCTestCase {
    
    override class func setUp() {
        swift_task_enqueueGlobal_hook = { job, _ in
            MainActor.shared.enqueue(job)
        }
    }

    func testLoadingDataAndCreatingScheduleBeforeEvent() async throws {
        
        
        
        let testSchedule = Schedule(
            scheduleItems: ScheduleItem.previewData,
            dayStartsAtNoon: false,
            timeZone: .current
        )
        
        let event = Event.previewData
        let testStages = Stages.previewData
        let today = CalendarDate(year: 2022, month: 9, day: 2).atTimeOfDay(hour: 22)
        
        let testStore = TestStore(
            initialState: ScheduleManagementDomain.State(),
            reducer: { ScheduleManagementDomain() }
        ) {
            $0.eventClient.getEvent = { .just(event) }
            $0.stageClient.getStages = { .just(testStages) }
            $0.scheduleClient.getSchedule = { .just(testSchedule)}
            $0.date = .constant(today)
        }
                
        await testStore.send(.task)
        
        await testStore.receive(.dataUpdate(.stages(testStages))) {
            $0.stages = testStages
        }
        
        await testStore.receive(.dataUpdate(.event(event))) {
            $0.event = event
        }
        
        await testStore.receive(.dataUpdate(.schedule(testSchedule))) {
            $0.schedule = testSchedule
            
            $0.scheduleState = ScheduleDomain.State(
                schedule: testSchedule,
                stages: testStages,
                event: event,
                selectedDate: event.startDate
            )
        }
    }
    
    
    /// Testing selecting the correct date when the "dayStartsAtNoon" flag is enabled
    /// This tests that if today is during the festival, and it's before midnight, today should be selected.
    func testSelectedDateDayStartsAtNoonBeforeMidnight() async throws {
        
        var initialState = ScheduleManagementDomain.State()
        
        let testStages = Stages.previewData
        let testSchedule = Schedule.previewData

        initialState.stages = testStages
        initialState.schedule = testSchedule
        
        // Set up test event
        var testEvent = Event.previewData
        
        testEvent.startDate = CalendarDate(year: 2023, month: 6, day: 12)
        testEvent.endDate = CalendarDate(year: 2023, month: 6, day: 15)
        testEvent.dayStartsAtNoon = true
        
        let today = CalendarDate(year: 2023, month: 6, day: 13)
        
        let testStore = TestStore(
            initialState: initialState,
            reducer: { ScheduleManagementDomain() }
        ) {
            $0.date = .constant(today.atTimeOfDay(hour: 22)) //
        }
        
        await testStore.send(.dataUpdate(.event(testEvent))) {
            $0.event = testEvent
            
            $0.scheduleState = ScheduleDomain.State(
                schedule: testSchedule,
                stages: testStages,
                event: testEvent,
                selectedDate: today
            )
        }
    }
    
    /// Testing selecting the correct date when the "dayStartsAtNoon" flag is enabled
    /// This tests that if today is during the festival, and it's before midnight, today should be selected.
    func testSelectedDateDayStartsAtNoonAfterMidnight() async throws {
        
        var initialState = ScheduleManagementDomain.State()
        
        let testStages = Stages.previewData
        let testSchedule = Schedule.previewData

        initialState.stages = testStages
        initialState.schedule = testSchedule
        
        // Set up test event
        var testEvent = Event.previewData
        
        testEvent.startDate = CalendarDate(year: 2023, month: 6, day: 12)
        testEvent.endDate = CalendarDate(year: 2023, month: 6, day: 15)
        testEvent.dayStartsAtNoon = true
        
        let today = CalendarDate(year: 2023, month: 6, day: 14) // Set up today as
        
        let testStore = TestStore(
            initialState: initialState,
            reducer: { ScheduleManagementDomain() }
        ) {
            $0.date = .constant(today.atTimeOfDay(hour: 2)) //
        }
        
        await testStore.send(.dataUpdate(.event(testEvent))) {
            $0.event = testEvent
            
            $0.scheduleState = ScheduleDomain.State(
                schedule: testSchedule,
                stages: testStages,
                event: testEvent,
                selectedDate: today.adding(days: -1)
            )
        }
    }
    
    /// Testing selecting the correct date when you look at a schedule after the festival
    func testSelectedDayTodayAfterFestival() async throws {
        
        var initialState = ScheduleManagementDomain.State()
        
        let testStages = Stages.previewData
        let testSchedule = Schedule.previewData
        
        initialState.stages = testStages
        initialState.schedule = testSchedule
        
        // Set up test event
        var testEvent = Event.previewData
        
        testEvent.startDate = CalendarDate(year: 2022, month: 09, day: 08)
        testEvent.endDate = CalendarDate(year: 2022, month: 09, day: 10)
        testEvent.dayStartsAtNoon = true
        
        let today = CalendarDate(year: 2023, month: 07, day: 12) // Set up today as
        
        let testStore = TestStore(
            initialState: initialState,
            reducer: { ScheduleManagementDomain() }
        ) {
            $0.date = .constant(today.atTimeOfDay(hour: 2)) //
        }
        
        await testStore.send(.dataUpdate(.event(testEvent))) {
            $0.event = testEvent
            
            $0.scheduleState = ScheduleDomain.State(
                schedule: testSchedule,
                stages: testStages,
                event: testEvent,
                selectedDate: CalendarDate(year: 2022, month: 09, day: 09)
            )
        }
    }
}

typealias Original =
  @convention(thin) (UnownedJob) -> Void

typealias Hook =
  @convention(thin) (UnownedJob, Original) -> Void

private let _swift_task_enqueueGlobal_hook = dlsym(
  dlopen(nil, 0), "swift_task_enqueueGlobal_hook"
)
.assumingMemoryBound(to: Hook?.self)

var swift_task_enqueueGlobal_hook: Hook? {
  get { _swift_task_enqueueGlobal_hook.pointee }
  set { _swift_task_enqueueGlobal_hook.pointee = newValue }
}
