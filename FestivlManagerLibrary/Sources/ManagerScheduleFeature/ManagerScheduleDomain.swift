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
import Services

var gridColor: Color = Color(NSColor.controlColor)

public struct ManagerScheduleState: Equatable {
    public init(
        event: Event,
        selectedDate: Date,
        zoomAmount: CGFloat,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        artistSets: IdentifiedArrayOf<ArtistSet>,
        groupSets: IdentifiedArrayOf<GroupSet>,
        addEditArtistSetState: AddEditArtistSetState?
    ) {
        self.event = event
        self.selectedDate = selectedDate
        self.zoomAmount = zoomAmount
        self.artists = artists
        self.stages = stages
        self.artistSets = artistSets
        self.groupSets = groupSets
        self.addEditArtistSetState = addEditArtistSetState

    }

    public let event: Event
    public var selectedDate: Date
    @BindableState public var zoomAmount: CGFloat

    public let artists: IdentifiedArrayOf<Artist>
    public let stages: IdentifiedArrayOf<Stage>
    public var artistSets: IdentifiedArrayOf<ArtistSet>
    public var groupSets: IdentifiedArrayOf<GroupSet>

    public var loading: Bool = false

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

    // MARK: Optimization Point
    var artistSetCardStates: IdentifiedArrayOf<ArtistSetCardState> {
        get {

            artistSets.compactMap {
                guard let stage = stages[id: $0.stageID] else { return nil }

                return ArtistSetCardState(artistSet: $0, stage: stage, event: event)
            }
            .asIdentifedArray
        }

        set {
            artistSets = newValue.map { $0.artistSet }.asIdentifedArray
        }
    }

    var artistSetsForDate: IdentifiedArrayOf<ArtistSet> {
        artistSets.filter {
            $0.isOnDate(selectedDate, dayStartsAtNoon: event.dayStartsAtNoon)
        }
    }

    // MARK: Optimization Point
    var displayedArtistSetCardStates: IdentifiedArrayOf<ArtistSetCardState> {
        artistSetsForDate.compactMap {
            guard let stage = stages[id: $0.stageID] else { return nil }

            return ArtistSetCardState(artistSet: $0, stage: stage, event: event)
        }
        .asIdentifedArray
    }
}

public enum ManagerScheduleAction: BindableAction {
    case binding(_ action: BindingAction<ManagerScheduleState>)
    case headerAction(TimelineHeaderAction)
    case addEditArtistSetAction(AddEditArtistSetAction)

    case addEditArtistSetButtonPressed

    case didMoveArtistSet(ArtistSet, newStage: Stage, newTime: Date)
    case finishedSavingArtistSetMove(ArtistSet)

    case didDropArtist(Artist, stage: Stage, time: Date)
    case finishedSavingArtistDrop(ArtistSet)

    case deleteArtistSet(ArtistSet)
    case finishedDeletingArtistSet

    case artistSetCard(id: ArtistSetCardState.ID, action: ArtistSetCardAction)
}

public struct ManagerScheduleEnvironment {
    var artistSetService: () -> ArtistSetServiceProtocol

    public init(
        artistSetService: @escaping () -> ArtistSetServiceProtocol = { ArtistSetService.shared }
    ) {
        self.artistSetService = artistSetService
    }
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

    artistSetCardReducer.forEach(
        state: \ManagerScheduleState.artistSetCardStates,
        action: /ManagerScheduleAction.artistSetCard,
        environment: { _ in .init() }
    ),

    Reducer { state, action, environment in
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

        case .didMoveArtistSet(let artistSet, let newStage, let newTime):
            state.loading = true
            return updateArtistSet(
                artistSet,
                newStage: newStage,
                newTime: newTime,
                eventID: state.event.id!,
                environment: environment
            )

        case .didDropArtist(let artist, let stage, let time):

            state.loading = true

            return createArtistSet(
                artist,
                stage: stage,
                time: time,
                eventID: state.event.id!,
                environment: environment
            )

        case .addEditArtistSetAction(.closeModal):
            state.addEditArtistSetState = nil
            return .none

        case .deleteArtistSet(let artistSet):

            return deleteArtistSet(artistSet, eventID: state.event.id!, environment: environment)

        case .finishedSavingArtistSetMove, .finishedSavingArtistDrop, .finishedDeletingArtistSet:
            state.loading = false
            return .none

        case .artistSetCard(id: let id, action: .didTap):
            guard let artistSet = state.artistSets[id: id] else { return .none }
            state.addEditArtistSetState = .init(
                editing: artistSet,
                event: state.event,
                artists: state.artists,
                stages: state.stages
            )

            return .none

        case .artistSetCard(_, action: .didFinishDragging):
            state.loading = true
            return .none

        case .artistSetCard(_, action: .didFinishSavingDrag):
            state.loading = false
            return .none

        case .artistSetCard:
            return .none
            
        case .headerAction, .addEditArtistSetAction:
            return .none
        }
    }
    .binding()
)


private func updateArtistSet(
    _ artistSet: ArtistSet,
    newStage: Stage,
    newTime: Date,
    eventID: String,
    environment: ManagerScheduleEnvironment
) -> Effect<ManagerScheduleAction, Never> {
    var artistSet = artistSet

    artistSet.stageID = newStage.id!

    let roundedNewTime = newTime.round(precision: 15.minutes)

    let setLength = artistSet.setLength

    artistSet.startTime = roundedNewTime
    artistSet.endTime = roundedNewTime + setLength

    return Effect.asyncTask {
        try await environment.artistSetService()
            .updateArtistSet(
                artistSet,
                eventID: eventID
            )
    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        ManagerScheduleAction.finishedSavingArtistSetMove(artistSet)
    }
    .eraseToEffect()
}

private func createArtistSet(
    _ artist: Artist,
    stage: Stage,
    time: Date,
    eventID: String,
    environment: ManagerScheduleEnvironment
) -> Effect<ManagerScheduleAction, Never> {

    let time = time.round(precision: 15.minutes)
    let set = ArtistSet(
        id: nil,
        artistID: artist.id!,
        artistName: artist.name,
        stageID: stage.id!,
        startTime: time,
        endTime: time + 1.hours
    )

    return Effect.asyncTask {
        try await environment.artistSetService()
            .createArtistSet(set, eventID: eventID)
    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        ManagerScheduleAction.finishedSavingArtistDrop(set)
    }
    .eraseToEffect()
}


private func deleteArtistSet(
    _ artistSet: ArtistSet,
    eventID: String,
    environment: ManagerScheduleEnvironment
) -> Effect<ManagerScheduleAction, Never> {
    return Effect.asyncTask {
        try await environment.artistSetService()
            .deleteArtistSet(artistSet, eventID: eventID)
    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        ManagerScheduleAction.finishedDeletingArtistSet
    }
    .eraseToEffect()
}
