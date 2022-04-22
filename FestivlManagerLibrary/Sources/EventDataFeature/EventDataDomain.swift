//
// SiteMapDomain.swift
//
//
//  Created by Woody on 4/22/2022.
//

import ComposableArchitecture
import Models
import AppKit
import Services

public struct EventDataState: Equatable {
    public init(event: Event) {
        self.event = event
    }

    public let event: Event
}

public enum EventDataAction {
    case didSelectSiteMapImage(NSImage)
    case didRemoveSiteMapImage

    case finishedUpdatingEvent
    case uploadedImage(URL)
}

public struct EventDataEnvironment {

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

public let eventDataReducer = Reducer<EventDataState, EventDataAction, EventDataEnvironment> { state, action, environment in
    switch action {
    case .didSelectSiteMapImage(let image):
        return uploadImage(image, environment: environment)

    case .didRemoveSiteMapImage:
        var event = state.event

        event.siteMapImageURL = nil
        return updateEvent(event: event, environment: environment)

    case .finishedUpdatingEvent:
        return .none

    case .uploadedImage(let url):

        var event = state.event
        event.siteMapImageURL = url

        return updateEvent(event: event, environment: environment)
    }
}

private func uploadImage(_ image: NSImage, environment: EventDataEnvironment) -> Effect<EventDataAction, Never> {
    return Effect.asyncTask {
        do {
            let url = try await environment.imageService().uploadImage(image, fileName: environment.uuid().uuidString)

            return .uploadedImage(url)
        } catch {
            return .finishedUpdatingEvent
        }
    }
}

private func updateEvent(event: Event, environment: EventDataEnvironment) -> Effect<EventDataAction, Never> {
    return Effect.asyncTask {
        do {
            try await environment.eventService().updateEvent(newData: event)
            return .finishedUpdatingEvent
        } catch {
            return .finishedUpdatingEvent
        }
    }
    .receive(on: DispatchQueue.main)
    .eraseToEffect()
}
