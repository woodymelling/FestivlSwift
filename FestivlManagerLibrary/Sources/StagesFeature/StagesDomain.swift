//
// StagesDomain.swift
//
//
//  Created by Woody on 3/22/2022.
//

import ComposableArchitecture
import Models
import Services
import AddEditStageFeature
import StageDetailFeature

public struct StagesState: Equatable {
    public init(
        stages: IdentifiedArrayOf<Stage>,
        event: Event,
        selectedStage: Stage?,
        addEditStageState: AddEditStageState?,
        isPresentingDeleteConfirmation: Bool
    ) {
        self.stages = stages
        self.event = event
        self.selectedStage = selectedStage
        self.addEditStageState = addEditStageState
        self.isPresentingDeleteConfirmation = isPresentingDeleteConfirmation
    }

    public var stages: IdentifiedArrayOf<Stage>
    public var event: Event

    @BindableState public var selectedStage: Stage?
    @BindableState public var addEditStageState: AddEditStageState?

    public var isPresentingDeleteConfirmation: Bool

    var stageDetailState: StageDetailState? {
        get {
            guard let selectedStage = selectedStage else {
                return nil
            }

            return .init(
                stage: selectedStage,
                event: event,
                isPresentingDeleteConfirmation: isPresentingDeleteConfirmation
            )
        }

        set {
            guard let newValue = newValue else { return }

            self.selectedStage = newValue.stage
            self.event = newValue.event
            self.isPresentingDeleteConfirmation = newValue.isPresentingDeleteConfirmation
        }
    }
}

public enum StagesAction: BindableAction {
    case stagesReordered(fromOffsets: IndexSet, toOffset: Int)
    case binding(_ action: BindingAction<StagesState>)
    case addStageButtonPressed
    case addEditStageAction(AddEditStageAction)
    case stageDetailAction(StageDetailAction)
}

public struct StagesEnvironment {

    var stageService: () -> StageServiceProtocol

    public init(stageService: @escaping () -> StageServiceProtocol = { StageService.shared }) {
        self.stageService = stageService
    }
}

public let stagesReducer = Reducer<StagesState, StagesAction, StagesEnvironment>.combine (

    addEditStageReducer.optional().pullback(
        state: \.addEditStageState,
        action: /StagesAction.addEditStageAction,
        environment: { _ in .init() }
    ),

    stageDetailReducer.optional().pullback(
        state: \.stageDetailState,
        action: /StagesAction.stageDetailAction,
        environment: { _ in .init() }
    ),

    Reducer { state, action, environment in
        switch action {
        case .stagesReordered(let source, let destination):
            state.stages.move(fromOffsets: source, toOffset: destination)

            let stages = state.stages
            let eventID = state.event.id!

            return updateStageSortOrder(newOrder: state.stages, eventID: state.event.id!, environment: environment)

        case .addStageButtonPressed:
            state.addEditStageState = .init(
                eventID: state.event.id!,
                stageCount: state.stages.count
            )
            return .none

        case .addEditStageAction(.closeModal(let navigateToStage)):
            if let navigateToStage = navigateToStage {
                state.stages[id: navigateToStage.id] = navigateToStage

                state.selectedStage = navigateToStage
            }

            state.addEditStageState = nil

            return .none

        case .stageDetailAction(.editStage):
            guard let selectedStage = state.selectedStage else {
                return .none
            }

            state.addEditStageState = .init(
                editing: selectedStage,
                eventID: state.event.id!,
                stageCount: state.stages.count
            )

            return .none

        case .stageDetailAction(.stageDeletionSucceeded):
            state.selectedStage = nil
            state.isPresentingDeleteConfirmation = false
            return .none

        case .addEditStageAction, .stageDetailAction:
            return .none

        case .binding:
            return .none
        }
    }
    .binding()
)

private func updateStageSortOrder(
    newOrder stages: IdentifiedArrayOf<Stage>,
    eventID: EventID,
    environment: StagesEnvironment
) -> Effect<StagesAction, Never> {
    return .fireAndForget {
        Task {
            var stages = stages
            for (index, stage) in stages.enumerated() {
                stages[id: stage.id]?.sortIndex = index
            }

            try? await environment
                .stageService()
                .updateStageSortOrder(newOrder: stages, eventID: eventID)
        }
    }
}
