//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/1/22.
//

import Foundation
import ComposableArchitecture
import Models
import Services

public struct ArtistSetCardState: Equatable, Identifiable {
    var artistSet: ArtistSet
    var stage: Stage
    let event: Event

    public var id: ArtistSet.ID {
        return artistSet.id
    }
}

struct ArtistSetCardEnvironment {
    var artistSetService: () -> ArtistSetServiceProtocol

    public init(
        artistSetService: @escaping () -> ArtistSetServiceProtocol = { ArtistSetService.shared }
    ) {
        self.artistSetService = artistSetService
    }
}

public enum ArtistSetCardAction {
    case didTap
    case didDrag(newEndTime: Date)
    case didFinishDragging
    case didFinishSavingDrag
}

let artistSetCardReducer = Reducer<ArtistSetCardState, ArtistSetCardAction, ArtistSetCardEnvironment> { state, action, environment in
    switch action {
    case .didTap:
        return .none
    case .didDrag(let newEndTime):
        state.artistSet.endTime = newEndTime.round(precision: 5.minutes)
        return .none
    case .didFinishDragging:

        return saveArtistSetDrag(
            artistSet: state.artistSet,
            eventID: state.event.id!,
            environment: environment
        )

    case .didFinishSavingDrag:
        return .none
    }

}

private func saveArtistSetDrag(
    artistSet: ArtistSet,
    eventID: EventID,
    environment: ArtistSetCardEnvironment
) -> Effect<ArtistSetCardAction, Never> {
    Effect.asyncTask {
        try await environment.artistSetService()
            .updateArtistSet(artistSet, eventID: eventID)
    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        ArtistSetCardAction.didFinishSavingDrag
    }
    .eraseToEffect()

}

