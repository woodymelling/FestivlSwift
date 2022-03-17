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

public struct CreateArtistState: Equatable, Identifiable {
    public var id: UUID = UUID.init()
    
    public init(editing artist: Artist, eventID: EventID) {
        self.mode = .edit(originalArtist: artist)
        self.eventID = eventID

        name = artist.name
        description = artist.description ?? ""
        tierStepperValue = artist.tier ?? 0
        includeInExplore = artist.tier != nil
        soundcloudURL = artist.soundcloudURL ?? ""
        spotifyURL = artist.spotifyURL ?? ""
        websiteURL = artist.websiteURL ?? ""
    }

    public init(eventID: EventID) {
        self.mode = .create
        self.eventID = eventID
    }
    
    var eventID: EventID

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
    
    var didUpdateImage = false
}

public enum CreateArtistAction: BindableAction {
    case binding(_ action: BindingAction<CreateArtistState>)
    case saveButtonPressed
    case finishedUploadingArtist(Artist)
    case closeModal(navigateTo: Artist?)
}

public struct CreateArtistEnvironment {
    public var artistService: () -> ArtistServiceProtocol
    public var imageService: () -> ImageServiceProtocol
    public var uuid: () -> UUID
    
    public init(
        artistService: @escaping () -> ArtistServiceProtocol = { ArtistService.shared },
        imageService: @escaping () -> ImageServiceProtocol = { ImageService.shared },
        uuid: @escaping () -> UUID = UUID.init
    ) {
        self.artistService = artistService
        self.imageService = imageService
        self.uuid = uuid
    }
}

public let createArtistReducer = Reducer<CreateArtistState, CreateArtistAction, CreateArtistEnvironment> { state, action, environment in
    switch action {
    case .binding(\.$image):
        state.didUpdateImage = true
        return .none
        
    case .binding:
        return .none
        
    case .saveButtonPressed:
        
        var artist = Artist(
            name: state.name,
            description: state.description,
            tier: state.includeInExplore ? state.tierStepperValue : nil,
            imageURL: nil,
            soundcloudURL: state.soundcloudURL,
            websiteURL: state.websiteURL,
            spotifyURL: state.spotifyURL
        )
        
        // Create immutable copies so that we don't capture state in the closure
        let image = state.image
        let eventID = state.eventID
        let didUpdateImage = state.didUpdateImage
        let mode = state.mode
 
        return Effect.asyncTask {

            if let image = image, didUpdateImage {
                let imageURL = try await environment.imageService().uploadImage(
                    image,
                    fileName: environment.uuid().uuidString
                )
                artist.imageURL = imageURL
            }
            
            switch mode {
            case .create:
                artist = try await environment.artistService().createArtist(
                    artist: artist,
                    eventID: eventID
                )
                
            case let .edit(originalArtist: originalArtist):
                artist.id = originalArtist.id
                try await environment.artistService().updateArtist(
                    artist: artist,
                    eventID: eventID
                )
            }

        }
        .receive(on: DispatchQueue.main)
        .map { _ in
            .finishedUploadingArtist(artist)
        }
        .eraseToEffect()
    case .finishedUploadingArtist(let artist):
        return Effect(value: .closeModal(navigateTo: artist))
    case .closeModal:
        return .none
    }
}
.binding()
