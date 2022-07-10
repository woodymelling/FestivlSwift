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
        schedule: ManagerSchedule,
        liveSchedule: ManagerSchedule,
        hasUnpublishedChanges: Bool,
        addEditArtistSetState: AddEditArtistSetState?,
        artistSearchText: String
    ) {
        self.event = event
        self.selectedDate = selectedDate
        self.zoomAmount = zoomAmount
        self.artists = artists
        self.stages = stages
        self.schedule = schedule
        self.liveSchedule = liveSchedule
        self.hasUnpublishedChanges = hasUnpublishedChanges
        self.addEditArtistSetState = addEditArtistSetState
        self.artistSearchText = artistSearchText
    }

    public let event: Event
    public var selectedDate: Date
    @BindableState public var zoomAmount: CGFloat

    @BindableState public var artistSearchText: String

    public let artists: IdentifiedArrayOf<Artist>
    public let stages: IdentifiedArrayOf<Stage>
    public var schedule: ManagerSchedule
    public var liveSchedule: ManagerSchedule

    public var loading: Bool = false
    public var hasUnpublishedChanges: Bool

    @BindableState public var addEditArtistSetState: AddEditArtistSetState?
    

    var timelineHeight: CGFloat {
        return 1000 * zoomAmount
    }

    var headerState: TimelineHeaderState {
        get {

            var festivalDates = Set(event.festivalDates)

            for artistSet in liveSchedule.artistSets {
                festivalDates.insert(artistSet.startTime.startOfDay(dayStartsAtNoon: event.dayStartsAtNoon))
            }

            for groupSet in liveSchedule.groupSets {
                festivalDates.insert(groupSet.startTime.startOfDay(dayStartsAtNoon: event.dayStartsAtNoon))
            }

            return .init(
                selectedDate: selectedDate,
                stages: stages,
                festivalDates: Array(festivalDates).sorted()
            )
        }

        set {
            self.selectedDate = newValue.selectedDate
        }
    }

    // MARK: Optimization Point
    var scheduleCardStates: IdentifiedArrayOf<ScheduleCardState> {
        get {

            let artistSets: [ScheduleCardState] = schedule.artistSets.compactMap {
                guard let stage = stages[id: $0.stageID] else { return nil }

                return ScheduleCardState(
                    set: $0.asScheduleItem(),
                    stage: stage,
                    event: event
                )
            }

            let groupSets: [ScheduleCardState] = schedule.groupSets.compactMap {
                guard let stage = stages[id: $0.stageID] else { return nil }

                return ScheduleCardState(
                    set: $0.asScheduleItem(),
                    stage: stage,
                    event: event
                )
            }


            return (artistSets + groupSets).asIdentifedArray
        }

        set {
            // TODO: I think endTime is the only thing that can be changed in here, add additional if neccesary
            for card in newValue {
                switch card.set.type {
                case .artistSet:
                    schedule.artistSets[id: card.id]?.endTime = card.set.endTime

                case .groupSet:
                    schedule.groupSets[id: card.id]?.endTime = card.set.endTime
                }
            }
        }
    }

    // MARK: Optimization Point
    var displayedScheduleCardStates: IdentifiedArrayOf<ScheduleCardState> {
        scheduleCardStates.filter {
            $0.set.isOnDate(selectedDate, dayStartsAtNoon: event.dayStartsAtNoon)
        }
    }
}

public enum ManagerScheduleAction: BindableAction {
    case binding(_ action: BindingAction<ManagerScheduleState>)
    case headerAction(TimelineHeaderAction)
    case addEditArtistSetAction(AddEditArtistSetAction)
    case onAppear

    case scheduleUpdate(ManagerSchedule)

    case addEditArtistSetButtonPressed

    case didMoveScheduleCard(ScheduleItem, newStage: Stage, newTime: Date)
    case finishedSavingScheduleCardMove(ScheduleItem)

    case didDropArtist(Artist, stage: Stage, time: Date)
    case finishedSavingArtistDrop(ArtistSet)

    case deleteArtistSet(ArtistSet)
    case finishedDeletingArtistSet

    case deleteGroupSet(GroupSet)
    case finishedDeletingGroupSet

    case scheduleCard(id: ScheduleCardState.ID, action: ScheduleCardAction)

    case publishChanges
    case finishedPublishingChanges
    case changesPublisherUpdate(Bool)
    case adjustTimeZone
}

public struct ManagerScheduleEnvironment {
    var scheduleService: () -> PublishableScheduleServiceProtocol

    public init(
        artistSetService: @escaping () -> PublishableScheduleServiceProtocol
    ) {
        self.scheduleService = artistSetService
    }
}

public let managerScheduleReducer = Reducer<ManagerScheduleState, ManagerScheduleAction, ManagerScheduleEnvironment>.combine(

    addEditArtistSetReducer.optional().pullback(
        state: \ManagerScheduleState.addEditArtistSetState,
        action: /ManagerScheduleAction.addEditArtistSetAction,
        environment: {
            .init(artistSetService: $0.scheduleService)
        }
    ),

    timelineHeaderReducer.pullback(
        state: \ManagerScheduleState.headerState,
        action: /ManagerScheduleAction.headerAction,
        environment: { _ in .init() }
    ),

    scheduleCardReducer.forEach(
        state: \ManagerScheduleState.scheduleCardStates,
        action: /ManagerScheduleAction.scheduleCard,
        environment: { _ in .init() }
    ),

    Reducer { state, action, environment in
        switch action {
        case .binding:
            return .none

        case .onAppear:
            return .merge(
                environment
                    .scheduleService()
                    .schedulePublisher(eventID: state.event.id!)
                    .map {
                        ManagerScheduleAction.scheduleUpdate(.init(artistSets: $0.0, groupSets: $0.1))
                    }
                    .eraseErrorToPrint(errorSource: "Schedule error")
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect(),

                environment
                    .scheduleService()
                    .hasChangesPublisher
                    .map {
                        ManagerScheduleAction.changesPublisherUpdate($0)
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
            )

        case .changesPublisherUpdate(let hasChanges):
            state.hasUnpublishedChanges = hasChanges
            return .none

        case .scheduleUpdate(let newSchedule):
            state.schedule = newSchedule
            return .none
            

        case .addEditArtistSetButtonPressed:
            state.addEditArtistSetState = .init(
                event: state.event,
                artists: state.artists,
                stages: state.stages
            )
            return .none

        case .didMoveScheduleCard(let artistSet, let newStage, let newTime):
            state.loading = true
            return updateArtistSet(
                artistSet,
                groupSets: state.schedule.groupSets,
                artistSets: state.schedule.artistSets,
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

        case .deleteGroupSet(let groupSet):
            return deleteGroupSet(groupSet, eventID: state.event.id!, environment: environment)

        case .finishedSavingScheduleCardMove, .finishedSavingArtistDrop, .finishedDeletingArtistSet, .finishedDeletingGroupSet:
            state.loading = false
            return .none

            

        case .scheduleCard(id: let id, action: .didTap):

            guard let set = state.scheduleCardStates[id: id]?.set else { return .none }

            switch set.type {
            case .artistSet:
                guard let artistSet = state.schedule.artistSets[id: id] else { return .none }
                state.addEditArtistSetState = .init(
                    editing: artistSet,
                    event: state.event,
                    artists: state.artists,
                    stages: state.stages
                )

            case .groupSet:
                guard let groupSet = state.schedule.groupSets[id: id] else { return .none }
                state.addEditArtistSetState = .init(
                    editing: groupSet,
                    event: state.event,
                    artists: state.artists,
                    stages: state.stages
                )
            }


            return .none

        case .scheduleCard(let id, action: .didFinishDragging):
            state.loading = true

            guard let card = state.scheduleCardStates[id: id] else { return .none }

            return saveArtistSetDrag(
                groupSets: state.schedule.groupSets,
                artistSets: state.schedule.artistSets,
                set: card.set,
                eventID: state.event.id!,
                environment: environment
            )

        case .scheduleCard(_, action: .didFinishSavingDrag):
            state.loading = false
            return .none

        case .scheduleCard:
            return .none
            
        case .headerAction, .addEditArtistSetAction:
            return .none

        case .publishChanges:

            let state = state
            return .task {
                do {
                    try await environment.scheduleService().publishChanges(eventID: state.event.id!)
                } catch {
                    fatalError(error.localizedDescription)
                }
                
                return .finishedPublishingChanges
            }
            .receive(on: DispatchQueue.main)
            .eraseToEffect()

        case .finishedPublishingChanges:
            return .none

        case .adjustTimeZone:
            
            var effects: [Effect<ManagerScheduleAction, Never>] = []
            
            for scheduleItem in state.scheduleCardStates {
                
                effects.append (
                    updateArtistSet(
                        scheduleItem.set,
                        groupSets: state.schedule.groupSets,
                        artistSets: state.schedule.artistSets,
                        newStage: scheduleItem.stage,
                        newTime: scheduleItem.set.startTime + 1.hours,
                        eventID: state.event.id!,
                        environment: environment
                    )
                )
            }
            
            return .concatenate(effects)
        }
    }
    .binding()
)


private func updateArtistSet(
    _ set: ScheduleItem,
    groupSets: IdentifiedArrayOf<GroupSet>,
    artistSets: IdentifiedArrayOf<ArtistSet>,
    newStage: Stage,
    newTime: Date,
    eventID: String,
    environment: ManagerScheduleEnvironment
) -> Effect<ManagerScheduleAction, Never> {


    let roundedNewTime = newTime.round(precision: 15.minutes)
    let setLength = set.setLength
    let startTime = roundedNewTime
    let endTime = roundedNewTime + setLength

    switch set.type {
    case .groupSet:
        guard var groupSet = groupSets[id: set.id] else {
            print("Failed to find group set with id: \(set.id!)")
            return .none
        }

        groupSet.stageID = newStage.id!
        groupSet.startTime = startTime
        groupSet.endTime = endTime

        return .asyncTask {
            do {
                try await environment.scheduleService().updateGroupSet(groupSet, eventID: eventID, batch: nil)
            } catch {
                print("Error updating group set:", error)
            }

            return .finishedSavingScheduleCardMove(groupSet.asScheduleItem())
        }

    case .artistSet:
        guard var artistSet = artistSets[id: set.id] else {
            print("Failed to find artist set with id: \(set.id!)")
            return .none
        }

        artistSet.stageID = newStage.id!
        artistSet.startTime = startTime
        artistSet.endTime = endTime

        return .asyncTask {
            do {
                try await environment.scheduleService().updateArtistSet(artistSet, eventID: eventID, batch: nil)
            } catch {
                print("Error updating artist set:", error)
            }

            return .finishedSavingScheduleCardMove(artistSet.asScheduleItem())
        }

    }
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
        try await environment.scheduleService()
            .createArtistSet(set, eventID: eventID, batch: nil)
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
        try await environment.scheduleService()
            .deleteArtistSet(artistSet, eventID: eventID, batch: nil)
    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        ManagerScheduleAction.finishedDeletingArtistSet
    }
    .eraseToEffect()
}

private func deleteGroupSet(
    _ groupSet: GroupSet,
    eventID: String,
    environment: ManagerScheduleEnvironment
) -> Effect<ManagerScheduleAction, Never> {
    return Effect.asyncTask {
        try await environment.scheduleService()
            .deleteGroupSet(groupSet, eventID: eventID, batch: nil)
    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        ManagerScheduleAction.finishedDeletingGroupSet
    }
    .eraseToEffect()
}

// Probably move this above to allow for access to the groupSets/artistSets array
private func saveArtistSetDrag(
    groupSets: IdentifiedArrayOf<GroupSet>,
    artistSets: IdentifiedArrayOf<ArtistSet>,
    set: ScheduleItem,
    eventID: EventID,
    environment: ManagerScheduleEnvironment
) -> Effect<ManagerScheduleAction, Never> {
    Effect.asyncTask {

        switch set.type {
        case .groupSet:

            guard let set = groupSets[id: set.id] else { return }
            try await environment.scheduleService()
                .updateGroupSet(set, eventID: eventID, batch: nil)
        case .artistSet:
            guard let set = artistSets[id: set.id] else { return }
            try await environment.scheduleService()
                .updateArtistSet(set, eventID: eventID, batch: nil)
        }

    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        ManagerScheduleAction.scheduleCard(id: set.id, action: .didFinishSavingDrag)
    }
    .eraseToEffect()

}
