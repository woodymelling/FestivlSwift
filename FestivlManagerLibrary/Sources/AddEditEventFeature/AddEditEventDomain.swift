//
// AddEditEventDomain.swift
//
//
//  Created by Woody on 4/8/2022.
//

import ComposableArchitecture
import Models
import SwiftUI
import Utilities
import Services

enum Mode: Equatable {
    case create
    case edit(originalEvent: Event)

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
            return "Create Event"
        case let .edit(originalEvent):
            return "Update Event (\(originalEvent.name))"
        }
    }
}

public struct AddEditEventState: Equatable, Identifiable {
    public var id = UUID()
    @BindableState var name: String = ""
    @BindableState var startDate: Date = Date()
    @BindableState var endDate: Date = Date(timeInterval: 1.days, since: Date())
    @BindableState var dayStartsAtNoon: Bool = false
    @BindableState var image: NSImage?
    @BindableState var selectedImage: NSImage?

    var mode: Mode
    var loading = false
    var didUpdateImage = false

    var imageURL: URL?
    
    public init() {
        self.mode = .create
    }

    public init(editing event: Event) {
        self.mode = .edit(originalEvent: event)

        self.name = event.name
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.dayStartsAtNoon = event.dayStartsAtNoon
        self.imageURL = event.imageURL
    }
}

public enum AddEditEventAction: BindableAction {
    case binding(_ action: BindingAction<AddEditEventState>)
    case loadImageIfRequired
    case imageLoaded(NSImage?)
    case saveButtonPressed
    case cancelButtonPressed
    case finishedUploadingEvent(Event)
    case closeModal(navigateTo: Event?)
}

public struct AddEditEventEnvironment {
    public var eventService: () -> EventListServiceProtocol
    public var imageService: () -> ImageServiceProtocol
    public var uuid: () -> UUID

    public init(
        eventService: @escaping () -> EventListServiceProtocol = { EventListService.shared },
        imageService: @escaping () -> ImageServiceProtocol = { ImageService.shared },
        uuid: @escaping () -> UUID = UUID.init
    ) {
        self.eventService = eventService
        self.imageService = imageService
        self.uuid = uuid
    }
}

public let addEditEventReducer = Reducer<AddEditEventState, AddEditEventAction, AddEditEventEnvironment> { state, action, environment in
    switch action {
    case .binding(\.$image):
        state.didUpdateImage = true
        return .none

    case .binding:
        return .none
        
    case .loadImageIfRequired:
        if let imageURL = state.imageURL {
            state.loading = true
            return Effect.asyncTask {
                let result = await NSImage.fromURL(url: imageURL)

                return .imageLoaded(result)
            }
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
        } else {
            return .none
        }

    case .imageLoaded(let image):
        state.loading = false
        state.image = image
        state.selectedImage = image

        return .none

    case .saveButtonPressed:

        state.loading = true

        var originalEvent: Event?
        if case let .edit(event) = state.mode {
            originalEvent = event
        }

        var event = Event(
            id: nil,
            name: state.name,
            startDate: state.startDate,
            endDate: state.endDate,
            dayStartsAtNoon: state.dayStartsAtNoon,
            imageURL: nil,
            siteMapImageURL: originalEvent?.siteMapImageURL,
            contactNumbers: originalEvent?.contactNumbers ?? .init(),
            address: originalEvent?.address ?? "",
            latitude: originalEvent?.latitude ?? "",
            longitude: originalEvent?.longitude ?? "",
            timeZone: originalEvent?.timeZone ?? ""
        )

        return uploadEvent(
            event: event,
            image: state.image,
            didUpdateImage: state.didUpdateImage,
            mode: state.mode,
            environment: environment
        )

    case .finishedUploadingEvent(let event):
        state.loading = false
        return Effect(value: .closeModal(navigateTo: event))

    case .closeModal:
        return .none

    case .cancelButtonPressed:
        return .init(value: .closeModal(navigateTo: nil))

    }
}
.binding()


private func uploadEvent(
    event: Event,
    image: NSImage?,
    didUpdateImage: Bool,
    mode: Mode,
    environment: AddEditEventEnvironment
) -> Effect<AddEditEventAction, Never> {

    var event = event
    return Effect.asyncTask {

        if let image = image, didUpdateImage {
            let imageURL = try await environment.imageService().uploadImage(
                image,
                fileName: environment.uuid().uuidString
            )
            event.imageURL = imageURL
        }

        switch mode {
        case .create:
            event = try await environment.eventService().createEvent(event)

        case let .edit(originalEvent: originalevent):
            event.id = originalevent.id
            try await environment.eventService().updateEvent(
                newData: event
            )
        }

    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        AddEditEventAction.finishedUploadingEvent(event)
    }
    .eraseToEffect()
}
