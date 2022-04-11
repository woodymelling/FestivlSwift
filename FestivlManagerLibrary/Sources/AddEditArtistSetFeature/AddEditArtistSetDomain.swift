//
// AddEditArtistSetDomain.swift
//
//
//  Created by Woody on 3/30/2022.
//

import ComposableArchitecture
import Models
import Services

enum Mode: Equatable {
    case create
    case edit(originalSet: ArtistSet)

    var title: String {
        switch self {
        case .create:
            return "Create Set"
        case .edit:
            return "Edit Set"
        }
    }
}

public struct AddEditArtistSetState: Equatable, Identifiable {
    public var id = UUID()

    public var event: Event

    public let artists: IdentifiedArrayOf<Artist>
    public let stages: IdentifiedArrayOf<Stage>

    @BindableState public var selectedArtist: Artist? = nil
    @BindableState public var selectedStage: Stage? = nil
    @BindableState public var selectedDate: Date
    @BindableState public var startTime: Date = Date()
    @BindableState public var endTime: Date = Date() + 1.hours

    public var errorText: String? = nil

    var mode: Mode
    var loading: Bool = false

    public init(event: Event, artists: IdentifiedArrayOf<Artist>, stages: IdentifiedArrayOf<Stage>) {
        self.mode = .create
        self.event = event
        self.artists = artists
        self.stages = stages

        self.selectedDate = event.festivalDates.first!.startOfDay(dayStartsAtNoon: event.dayStartsAtNoon)
    }

    public init(editing artistSet: ArtistSet, event: Event, artists: IdentifiedArrayOf<Artist>, stages: IdentifiedArrayOf<Stage>) {
        self.mode = .edit(originalSet: artistSet)

        self.event = event
        self.artists = artists
        self.stages = stages

        self.selectedDate = artistSet.startTime.startOfDay(dayStartsAtNoon: event.dayStartsAtNoon)
        self.startTime = artistSet.startTime
        self.endTime = artistSet.endTime
        self.selectedStage = stages[id: artistSet.stageID]
        self.selectedArtist = artists[id: artistSet.artistID]
    }
}

public enum AddEditArtistSetAction: BindableAction {
    case binding(_ action: BindingAction<AddEditArtistSetState>)
    case saveButtonPressed
    case cancelButtonPressed
    case saveValidationError(String)
    case finishedUploadingSet(ArtistSet)
    case closeModal(navigateTo: ArtistSet?)
}

public struct AddEditArtistSetEnvironment {
    var artistSetService: () -> ArtistSetServiceProtocol

    public init(
        artistSetService: @escaping () -> ArtistSetServiceProtocol = { ArtistSetService.shared }
    ) {
        self.artistSetService = artistSetService
    }
}

public let addEditArtistSetReducer = Reducer<AddEditArtistSetState, AddEditArtistSetAction, AddEditArtistSetEnvironment> { state, action, environment in
    switch action {
    case .binding:
        return .none
    case .saveButtonPressed:
        state.loading = true

        return saveArtistSet(state, environment: environment)
    case .cancelButtonPressed:

        return Effect(value: .closeModal(navigateTo: nil))

    case .saveValidationError(let errorText):
        state.loading = false
        state.errorText = errorText
        return .none
    case .finishedUploadingSet(let artistSet):
        state.loading = false

        return Effect(value: .closeModal(navigateTo: artistSet))

    case .closeModal:
        return .none
    }
}
.binding()

private func saveArtistSet(
    _ state: AddEditArtistSetState,
    environment: AddEditArtistSetEnvironment
) -> Effect<AddEditArtistSetAction, Never> {
    guard let selectedArtist = state.selectedArtist else {
        return Effect(value: .saveValidationError("You must select an artist"))
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

    var artistSet = ArtistSet(
        id: nil,
        artistID: selectedArtist.id!,
        artistName: selectedArtist.name,
        stageID: selectedStage.id!,
        startTime: setTime(for: state.startTime),
        endTime: setTime(for: state.endTime)
    )

    return Effect.asyncTask {
        switch state.mode {
        case .create:
            artistSet = try await environment.artistSetService()
                .createArtistSet(
                    artistSet,
                    eventID: state.event.id!
                )
        case .edit(let orignalSet):
            artistSet.id = orignalSet.id
            try await environment.artistSetService().updateArtistSet(
                artistSet,
                eventID: state.event.id!
            )
        }
    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        AddEditArtistSetAction.finishedUploadingSet(artistSet)
    }
    .eraseToEffect()
}
