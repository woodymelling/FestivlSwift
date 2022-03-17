//
// ManagerArtistsDomain.swift
//
//
//  Created by Woody on 3/10/2022.
//

import ComposableArchitecture
import Models
import CreateArtistFeature

public struct ManagerArtistsState: Equatable {
    public init(
        artists: IdentifiedArrayOf<Artist>,
        selectedArtist: Artist?,
        event: Event,
        createArtistState: CreateArtistState?
    ) {
        self.artists = artists
        self.selectedArtist = selectedArtist
        self.createArtistState = createArtistState
        self.event = event
    }

    public var artists: IdentifiedArrayOf<Artist>
    public var event: Event

    @BindableState public var selectedArtist: Artist?
    
    @BindableState public var createArtistState: CreateArtistState?
}

public enum ManagerArtistsAction: BindableAction {
    case binding(_ action: BindingAction<ManagerArtistsState>)
    case addArtistButtonPressed
    case createArtistAction(CreateArtistAction)
}

public struct ManagerArtistsEnvironment {
    public init() {}
}

public let managerArtistsReducer = Reducer<ManagerArtistsState, ManagerArtistsAction, ManagerArtistsEnvironment>.combine(
    
    createArtistReducer.optional().pullback(
        state: \.createArtistState,
        action: /ManagerArtistsAction.createArtistAction,
        environment: { _ in .init()}
    ),
    
    Reducer { state, action, _ in
        switch action {
        case .binding:
            return .none
        case .addArtistButtonPressed:
            state.createArtistState = .init(eventID: state.event.id!)
            return .none
        case .createArtistAction(.closeModal(let navigateToArtist)):
            if let navigateToArtist = navigateToArtist {
                state.artists[id: navigateToArtist.id] = navigateToArtist
                state.selectedArtist = navigateToArtist
            }
            state.createArtistState = nil
            return .none
        case .createArtistAction:
            return .none
        }
    }
    .binding()
)
