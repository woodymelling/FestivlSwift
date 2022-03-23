//
// StagesDomain.swift
//
//
//  Created by Woody on 3/22/2022.
//

import ComposableArchitecture
import Models
import Services

public struct StagesState: Equatable {
    public init(
        stages: IdentifiedArrayOf<Stage>,
        event: Event,
        selectedStage: Stage?
    ) {
        self.stages = stages
        self.event = event
        self.selectedStage = selectedStage
    }

    public var stages: IdentifiedArrayOf<Stage>
    public var event: Event

    @BindableState public var selectedStage: Stage?
}

public enum StagesAction: BindableAction {
    case stagesReordered(fromOffsets: IndexSet, toOffset: Int)
    case binding(_ action: BindingAction<StagesState>)
}

public struct StagesEnvironment {

    var stageService: () -> StageServiceProtocol

    public init(stageService: @escaping () -> StageServiceProtocol = { StageService.shared }) {
        self.stageService = stageService
    }
}

public let stagesReducer = Reducer<StagesState, StagesAction, StagesEnvironment> { state, action, environment in
    switch action {
    case .stagesReordered(let source, let destination):
        state.stages.move(fromOffsets: source, toOffset: destination)

        let stages = state.stages
        let eventID = state.event.id!

        return updateStageSortOrder(newOrder: state.stages, eventID: state.event.id!, environment: environment)
    case .binding:
        return .none
    }
}
.binding()

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
