//
// CreateArtistDomain.swift
//
//
//  Created by Woody on 3/14/2022.
//

import ComposableArchitecture
import Models
import AppKit
import Services

enum Mode: Equatable {
    case create
    case edit(originalArtist: Artist)

    var saveButtonName: String {
        switch self {
        case .edit:
            return "Update"
        case .create:
            return "Create"
        }
    }

    var viewTitle: String {
        switch self {
        case .create:
            return "Create Artist"
        case let .edit(originalArtist):
            return "Update Artist (\(originalArtist.name))"
        }
    }
}

public struct CreateArtistState: Equatable {
    public init(editing artist: Artist) {
        self.mode = .edit(originalArtist: artist)

        name = artist.name
        description = artist.description ?? ""
        tierStepperValue = artist.tier ?? 0
        includeInExplore = artist.tier != nil
        soundcloudURL = artist.soundcloudURL ?? ""
        spotifyURL = artist.spotifyURL ?? ""
        websiteURL = artist.websiteURL ?? ""
    }

    public init() {
        self.mode = .create
    }

    var mode: Mode
    @BindableState var name = ""
    @BindableState var description = ""
    @BindableState var image: NSImage?
    @BindableState var selectedImage: NSImage?
    @BindableState var tierStepperValue = 0
    @BindableState var includeInExplore: Bool = false
    @BindableState var soundcloudURL = ""
    @BindableState var spotifyURL = ""
    @BindableState var websiteURL = ""
}

public enum CreateArtistAction: BindableAction {
    case binding(_ action: BindingAction<CreateArtistState>)
    case saveButtonPressed
}

public struct CreateArtistEnvironment {
    public var artistService: () -> ArtistServiceProtocol
    public init(artistService: @escaping () -> ArtistServiceProtocol = { ArtistService.shared }) {
        self.artistService = artistService
    }
}

public let createArtistReducer = Reducer<CreateArtistState, CreateArtistAction, CreateArtistEnvironment> { state, action, environment in
    switch action {
    case .binding:
        return .none
    case .saveButtonPressed:

        return .none
    }
}
.binding()

//extension Effect {
//    static func asyncTask(async: @escaping () async throws -> Output) -> Effect {
//        return Effect.future { promise in
//            Task {
//                do {
//                    let output = try await async()
//                    promise(.success(output))
//                } catch {
//                    promise(.failure(error))
//                }
//            }
//        }
//    }
//}
