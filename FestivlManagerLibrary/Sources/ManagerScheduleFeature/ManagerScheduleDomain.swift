//
// ManagerScheduleDomain.swift
//
//
//  Created by Woody on 3/28/2022.
//

import ComposableArchitecture
import Models
import SwiftUI
import AddEditArtistSetFeature

var gridColor: Color = Color(NSColor.controlColor)

public struct ManagerScheduleState: Equatable {
    public init(
        event: Event,
        selectedDate: Date,
        zoomAmount: CGFloat,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        artistSets: IdentifiedArrayOf<ArtistSet>,
        addEditArtistSetState: AddEditArtistSetState?
    ) {
        self.event = event
        self.selectedDate = selectedDate
        self.zoomAmount = zoomAmount
        self.artists = artists
        self.stages = stages
        self.artistSets = artistSets
        self.addEditArtistSetState = addEditArtistSetState
    }

    public let event: Event
    public var selectedDate: Date
    @BindableState public var zoomAmount: CGFloat

    public let artists: IdentifiedArrayOf<Artist>
    public let stages: IdentifiedArrayOf<Stage>
    public let artistSets: IdentifiedArrayOf<ArtistSet>

    @BindableState public var addEditArtistSetState: AddEditArtistSetState?

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

    var artistSetsForDate: IdentifiedArrayOf<ArtistSet> {
        artistSets.filter {
            $0.isOnDate(selectedDate, dayStartsAtNoon: event.dayStartsAtNoon)
        }
    }
}

public enum ManagerScheduleAction: BindableAction {
    case binding(_ action: BindingAction<ManagerScheduleState>)
    case headerAction(TimelineHeaderAction)
    case addEditArtistSetAction(AddEditArtistSetAction)

    case addEditArtistSetButtonPressed
    case didTapArtistSet(ArtistSet)
}

public struct ManagerScheduleEnvironment {
    public init() {}
}

public let managerScheduleReducer = Reducer<ManagerScheduleState, ManagerScheduleAction, ManagerScheduleEnvironment>.combine(

    addEditArtistSetReducer.optional().pullback(
        state: \ManagerScheduleState.addEditArtistSetState,
        action: /ManagerScheduleAction.addEditArtistSetAction,
        environment: { _ in .init()}
    ),

    timelineHeaderReducer.pullback(
        state: \ManagerScheduleState.headerState,
        action: /ManagerScheduleAction.headerAction,
        environment: { _ in .init() }
    ),

    Reducer { state, action, _ in
        switch action {
        case .binding:
            return .none

        case .addEditArtistSetButtonPressed:
            state.addEditArtistSetState = .init(
                event: state.event,
                artists: state.artists,
                stages: state.stages
            )
            return .none

        case .didTapArtistSet(let artistSet):
            state.addEditArtistSetState = .init(
                editing: artistSet,
                event: state.event,
                artists: state.artists,
                stages: state.stages
            )

            return .none

        case .addEditArtistSetAction(.closeModal):
            state.addEditArtistSetState = nil
            return .none
            
        case .headerAction, .addEditArtistSetAction:
            return .none
        }
    }
    .binding()
)



