//
// ManagerArtistDetailDomain.swift
//
//
//  Created by Woody on 3/20/2022.
//

import ComposableArchitecture
import Models
import AppKit
import Services

public struct ManagerArtistDetailState: Equatable {
    public init(artist: Artist, event: Event, isPresentingDeleteConfirmation: Bool) {
        self.artist = artist
        self.event = event
        self.isPresentingDeleteConfirmation = isPresentingDeleteConfirmation
    }

    public var artist: Artist
    public var event: Event
    @BindableState public var isPresentingDeleteConfirmation: Bool
}

public enum ManagerArtistDetailAction: BindableAction {
    case binding(_ action: BindingAction<ManagerArtistDetailState>)
    case navigateToURL(URL)
    case subscribeToArtist
    case artistPublisherUpdate(Artist)
    case editArtist
    case deleteButtonPressed
    case deleteConfirmationCancelled
    case deleteArtist
    case artistDeletionSucceeded
}


public struct ManagerArtistDetailEnvironment {
    var openURL: (URL) -> Bool
    var artistService: () -> ArtistServiceProtocol

    public init(
        openURL: @escaping (URL) -> Bool = { NSWorkspace.shared.open($0) },
        artistService: @escaping () -> ArtistServiceProtocol = { ArtistService.shared }
    ) {
        self.openURL = openURL
        self.artistService = artistService
    }
}

public let managerArtistDetailReducer = Reducer<
    ManagerArtistDetailState,
    ManagerArtistDetailAction,
    ManagerArtistDetailEnvironment
> { state, action, environment in
    switch action {
    case .binding:
        return .none

    case .navigateToURL(let url):
        _ = environment.openURL(url)
        return .none

    case .subscribeToArtist:
        do {
            return try environment.artistService().watchArtist(
                artist: state.artist,
                eventID: state.event.id!
            )
            .map {
                ManagerArtistDetailAction.artistPublisherUpdate($0)
            }
            .eraseErrorToPrint(errorSource: "ArtistDetailPublisher")
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
        } catch {
            fatalError("Artist does not have ID")
        }

    case .artistPublisherUpdate(let artist):
        state.artist = artist
        return .none

    case .editArtist:
        return .none

    case .deleteButtonPressed:
        state.isPresentingDeleteConfirmation = true
        return .none

    case .deleteConfirmationCancelled:
        state.isPresentingDeleteConfirmation = false
        return .none

    case .deleteArtist:
        return deleteArtist(state.artist, eventID: state.event.id!, environment: environment)

    case .artistDeletionSucceeded:
        state.isPresentingDeleteConfirmation = false
        return .none
    }
}

private func deleteArtist(_ artist: Artist, eventID: EventID, environment: ManagerArtistDetailEnvironment) -> Effect<ManagerArtistDetailAction, Never> {
    return Effect.asyncTask {
        try await environment.artistService().deleteArtist(artist: artist, eventID: eventID)
    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        ManagerArtistDetailAction.artistDeletionSucceeded
    }
    .eraseToEffect()

}
