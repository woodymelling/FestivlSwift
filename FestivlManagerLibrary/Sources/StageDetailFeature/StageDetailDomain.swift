//
// StageDetailDomain.swift
//
//
//  Created by Woody on 3/23/2022.
//

import ComposableArchitecture
import Models
import Services

public struct StageDetailState: Equatable {
    public init(stage: Stage, event: Event, isPresentingDeleteConfirmation: Bool) {
        self.stage = stage
        self.event = event
        self.isPresentingDeleteConfirmation = isPresentingDeleteConfirmation
    }

    public var stage: Stage
    public var event: Event
    @BindableState public var isPresentingDeleteConfirmation: Bool
}

public enum StageDetailAction: BindableAction {
    case binding(_ action: BindingAction<StageDetailState>)
    case subscribeToStage
    case stagePublisherUpdate(Stage)
    case editStage
    case deleteButtonPressed
    case deleteConfirmationCancelled
    case deleteStage
    case stageDeletionSucceeded

}

public struct StageDetailEnvironment {
    public var stagesService: () -> StageServiceProtocol

    public init(stagesService: @escaping () -> StageServiceProtocol = { StageService.shared }) {
        self.stagesService = stagesService
    }
}

public let stageDetailReducer = Reducer<StageDetailState, StageDetailAction, StageDetailEnvironment> { state, action, environment in
    switch action {
    case .binding:
        return .none

    case .subscribeToStage:
        return subscribeToStage(
            stage: state.stage,
            event: state.event,
            environment: environment
        )

    case .stagePublisherUpdate(let stage):
        state.stage = stage
        return .none
    case .editStage:
        return .none // Handled at StageList level
    case .deleteButtonPressed:
        state.isPresentingDeleteConfirmation = true
        return .none

    case .deleteConfirmationCancelled:
        state.isPresentingDeleteConfirmation = false
        return .none

    case .deleteStage:
        return deleteStage(
            state.stage,
            eventID: state.event.id,
            environment: environment
        )
    case .stageDeletionSucceeded:
        state.isPresentingDeleteConfirmation = false
        return .none
    }
}

private func subscribeToStage(
    stage: Stage,
    event: Event,
    environment: StageDetailEnvironment
) -> Effect<StageDetailAction, Never> {
    do {
        return try environment.stagesService()
            .watchStage(
                stage: stage,
                eventID: event.id!
            )
            .map {
                StageDetailAction.stagePublisherUpdate($0)
            }
            .eraseErrorToPrint(errorSource: "StageDetailPublisher")
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    } catch {
        fatalError("Stage does not have ID")
    }
}

private func deleteStage(
    _ stage: Stage,
    eventID: EventID!,
    environment: StageDetailEnvironment
) -> Effect<StageDetailAction, Never> {
    return Effect.asyncTask {
        try await environment.stagesService().deleteStage(
            stage: stage,
            eventID: eventID
        )
    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        StageDetailAction.stageDeletionSucceeded
    }
    .eraseToEffect()
}
