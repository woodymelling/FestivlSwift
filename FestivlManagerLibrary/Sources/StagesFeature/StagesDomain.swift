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
        event: Event
    ) {
        self.stages = stages
        self.event = event
    }

    public var stages: IdentifiedArrayOf<Stage>
    public var event: Event
}

public enum StagesAction {
    case stagesReordered(fromOffsets: IndexSet, toOffset: Int)
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
    }
}

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
