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
    public init(artist: Artist, event: Event) {
        self.artist = artist
        self.event = event
    }

    public var artist: Artist
    public var event: Event
}

public enum ManagerArtistDetailAction {
    case navigateToURL(URL)
    case subscribeToArtist
    case artistPublisherUpdate(Artist)
    case editArtist
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

public let managerArtistDetailReducer = Reducer<ManagerArtistDetailState, ManagerArtistDetailAction, ManagerArtistDetailEnvironment> { state, action, environment in
    switch action {
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
    }
}
