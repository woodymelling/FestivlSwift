//
// ManagerArtistsDomain.swift
//
//
//  Created by Woody on 3/10/2022.
//

import ComposableArchitecture
import Models
import CreateArtistFeature
import ManagerArtistDetailFeature

public struct ManagerArtistsState: Equatable {
    public init(
        artists: IdentifiedArrayOf<Artist>,
        selectedArtist: Artist?,
        event: Event,
        createArtistState: CreateArtistState?,
        isPresentingDeleteConfirmation: Bool,
        bulkAddState: BulkAddState?
    ) {
        self.artists = artists
        self.selectedArtist = selectedArtist
        self.createArtistState = createArtistState
        self.event = event
        self.isPresentingDeleteConfirmation = isPresentingDeleteConfirmation
        self.bulkAddState = bulkAddState
    }

    public var artists: IdentifiedArrayOf<Artist>
    public var event: Event

    @BindableState public var selectedArtist: Artist?
    @BindableState public var createArtistState: CreateArtistState?
    @BindableState public var bulkAddState: BulkAddState?

    public var isPresentingDeleteConfirmation: Bool

    var artistDetailState: ManagerArtistDetailState? {
        get {
            guard let selectedArtist = selectedArtist else {
                return nil
            }

            return .init(
                artist: selectedArtist,
                event: event,
                isPresentingDeleteConfirmation: isPresentingDeleteConfirmation
            )
        }

        set {
            guard let newValue = newValue else { return }
            self.selectedArtist = newValue.artist
            self.event = newValue.event
            self.isPresentingDeleteConfirmation = newValue.isPresentingDeleteConfirmation
        }
    }
}

public enum ManagerArtistsAction: BindableAction {
    case binding(_ action: BindingAction<ManagerArtistsState>)
    case addArtistButtonPressed
    case bulkAddButtonPressed
    case createArtistAction(CreateArtistAction)
    case artistDetailAction(ManagerArtistDetailAction)
    case bulkAddAction(BulkAddAction)
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

    managerArtistDetailReducer.optional().pullback(
        state: \.artistDetailState,
        action: /ManagerArtistsAction.artistDetailAction,
        environment: { _ in .init() }
    ),

    bulkAddReducer.optional().pullback(
        state: \.bulkAddState,
        action: /ManagerArtistsAction.bulkAddAction,
        environment: { _ in .init() }
    ),
    
    Reducer { state, action, _ in
        switch action {
        case .binding:
            return .none
            
        case .addArtistButtonPressed:
            state.createArtistState = .init(eventID: state.event.id!)
            return .none

        case .bulkAddButtonPressed:

            state.bulkAddState = .init(eventID: state.event.id!)
            return .none

        case .createArtistAction(.closeModal(let navigateToArtist)):
            if let navigateToArtist = navigateToArtist {
                state.artists[id: navigateToArtist.id] = navigateToArtist
                state.selectedArtist = navigateToArtist
            }
            state.createArtistState = nil
            return .none

        case .bulkAddAction(.closeModal):
            state.bulkAddState = nil
            return .none

        case .artistDetailAction(.editArtist):
            guard let selectedArtist = state.selectedArtist else { return .none }
            state.createArtistState = .init(editing: selectedArtist, eventID: state.event.id!)
            return .none
            
        case .artistDetailAction(.artistDeletionSucceeded):
            state.selectedArtist = nil
            state.isPresentingDeleteConfirmation = false
            return .none

        case .artistDetailAction, .createArtistAction, .bulkAddAction:
            return .none
        }
    }
    .binding()
)
