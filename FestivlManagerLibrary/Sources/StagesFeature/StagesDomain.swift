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

public struct StagesState: Equatable {
    public init(
        stages: IdentifiedArrayOf<Stage>,
        event: Event,
        selectedStage: Stage?,
        addEditStageState: AddEditStageState?
    ) {
        self.stages = stages
        self.event = event
        self.selectedStage = selectedStage
        self.addEditStageState = addEditStageState
    }

    public var stages: IdentifiedArrayOf<Stage>
    public var event: Event

    @BindableState public var selectedStage: Stage?
    @BindableState public var addEditStageState: AddEditStageState?
}

public enum StagesAction: BindableAction {
    case stagesReordered(fromOffsets: IndexSet, toOffset: Int)
    case binding(_ action: BindingAction<StagesState>)
    case addStageButtonPressed
    case addEditStageAction(AddEditStageAction)
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

        case .addEditStageAction:
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

            try? await environment
                .stageService()
                .updateStageSortOrder(newOrder: stages, eventID: eventID)
        }
    }
}
