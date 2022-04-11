//
// AddEditGroupSetDomain.swift
//
//
//  Created by Woody on 4/10/2022.
//

import ComposableArchitecture
import Models
import Services

enum Mode: Equatable {
    case create
    case edit(originalSet: GroupSet)

    var title: String {
        switch self {
        case .create:
            return "Create Set"
        case .edit:
            return "Edit Set"
        }
    }
}

public struct AddEditGroupSetState: Equatable {
    public var id = UUID()
    public var event: Event

    public let artists: IdentifiedArrayOf<Artist>
    public let stages: IdentifiedArrayOf<Stage>

    @BindableState public var selectedArtists: [Artist] = []
    @BindableState public var selectedStage: Stage? = nil
    @BindableState public var selectedDate: Date
    @BindableState public var startTime: Date = Date()
    @BindableState public var endTime: Date = Date() + 1.hours

    public var errorText: String? = nil

    var mode: Mode
    var loading: Bool = false

    public init(
        event: Event,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>
    ) {
        self.mode = .create
        self.event = event
        self.artists = artists
        self.stages = stages

        self.selectedDate = event.festivalDates
            .first!
            .startOfDay(dayStartsAtNoon: event.dayStartsAtNoon)
    }

    public init(
        editing groupSet: GroupSet,
        event: Event,
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>
    ) {
        self.mode = .edit(originalSet: groupSet)

        self.event = event
        self.artists = artists
        self.stages = stages

        self.selectedDate = groupSet.startTime.startOfDay(
            dayStartsAtNoon: event.dayStartsAtNoon
        )

        self.startTime = groupSet.startTime
        self.endTime = groupSet.endTime
        self.selectedStage = stages[id: groupSet.stageID]
        self.selectedArtists = groupSet.artistIDs.compactMap {
            artists[id: $0]
        }
    }

}

public enum AddEditGroupSetAction: BindableAction {
    case binding(_ action: BindingAction<AddEditGroupSetState>)
    case saveButtonPressed
    case cancelButtonPressed
    case saveValidationError(String)
    case finishedUploadingSet(GroupSet)
    case closeModal(navigateTo: GroupSet?)

}

public struct AddEditGroupSetEnvironment {
    var artistSetService: () -> ArtistSetServiceProtocol

    public init(
        artistSetService: @escaping () -> ArtistSetServiceProtocol = { ArtistSetService.shared }
    ) {
        self.artistSetService = artistSetService
    }
}

public let addEditGroupSetReducer = Reducer<AddEditGroupSetState, AddEditGroupSetAction, AddEditGroupSetEnvironment> { state, action, environment in
    switch action {
    

    case .binding:
        return .none

    case .saveButtonPressed:
        state.loading = true
        return .none

    case .cancelButtonPressed:
        return Effect(value: .closeModal(navigateTo: nil))

    case .saveValidationError(let errorText):
        state.loading = false
        state.errorText = errorText
        return .none

    case .finishedUploadingSet(let groupSet):
        state.loading = false
        return Effect(value: .closeModal(navigateTo: groupSet))

    case .closeModal(navigateTo: let navigateTo):
        return .none
    }
}
.binding()

private func saveGroupSet(
    _ state: AddEditGroupSetState,
    environment: AddEditGroupSetEnvironment
) -> Effect<AddEditGroupSetAction, Never> {
    guard state.selectedArtists.count > 1 else {
        return Effect(value: .saveValidationError(
            "You must select more, for a single artist, use a regular artistSet"
        ))
    }

    guard let selectedStage = state.selectedStage else {
        return Effect(value: .saveValidationError("You must select a stage"))
    }

    guard state.startTime < state.endTime else {
        return Effect(value: .saveValidationError("Start time must be before the end time"))
    }

    func setTime(for time: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(
            byAdding: calendar.dateComponents([.hour, .minute], from: time),
            to: calendar.startOfDay(for: state.selectedDate)
        ) ?? Date()
    }

}
