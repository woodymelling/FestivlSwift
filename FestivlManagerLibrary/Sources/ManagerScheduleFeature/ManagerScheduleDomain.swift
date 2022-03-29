//
// ManagerScheduleDomain.swift
//
//
//  Created by Woody on 3/28/2022.
//

import ComposableArchitecture
import Models
import SwiftUI

var gridColor: Color = Color(NSColor.controlColor)

public struct ManagerScheduleState: Equatable {
    public var event: Event
    public var selectedDate: Date
    public var zoomAmount: CGFloat

    public var artists: IdentifiedArrayOf<Artist>
    public var stages: IdentifiedArrayOf<Stage>
    public var artistSets: IdentifiedArrayOf<ArtistSet>

    var timelineHeight: CGFloat {
        return 1000 * zoomAmount
    }

    var headerState: TimelineHeaderState {
        get {
            .init(
                selectedDate: selectedDate,
                stages: stages,
                festivalDates: event.festivalDates
            )
        }

        set {
            self.selectedDate = newValue.selectedDate
        }
    }
}

public enum ManagerScheduleAction {
    case headerAction(TimelineHeaderAction)
}

public struct ManagerScheduleEnvironment {
    public init() {}
}

public let managerScheduleReducer = Reducer<ManagerScheduleState, ManagerScheduleAction, ManagerScheduleEnvironment>.combine(
    timelineHeaderReducer.pullback(
        state: \ManagerScheduleState.headerState,
        action: /ManagerScheduleAction.headerAction,
        environment: { _ in
            .init()
        }
    ),

    Reducer { state, action, _ in
        return .none
    }
)



