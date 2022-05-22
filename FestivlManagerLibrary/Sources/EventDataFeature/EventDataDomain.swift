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
    public init(
        event: Event,
        contactNumbers: IdentifiedArrayOf<ContactNumber>,
        contactNumberText: String,
        contactNumberDescriptionText: String,
        contactNumberTitleText: String,
        addressText: String,
        latitudeText: String,
        longitudeText: String,
        timeZone: String
    ) {
        self.event = event
        self.contactNumbers = contactNumbers
        self.contactNumberText = contactNumberText
        self.contactNumberDescriptionText = contactNumberDescriptionText
        self.contactNumberTitleText = contactNumberTitleText
        self.address = addressText
        self.latitude = latitudeText
        self.longitude = longitudeText
        self.timeZone = timeZone
    }

    public var contactNumbers: IdentifiedArrayOf<ContactNumber> = []

    @BindableState public var contactNumberText: String
    @BindableState public var contactNumberDescriptionText: String
    @BindableState public var contactNumberTitleText: String
    @BindableState public var address: String = ""
    @BindableState public var latitude: String
    @BindableState public var longitude: String
    @BindableState public var timeZone: String = ""

    public let event: Event
}

public enum EventDataAction: BindableAction {

    case binding(_ action: BindingAction<EventDataState>)
    case didSelectSiteMapImage(NSImage)
    case didRemoveSiteMapImage

    case didTapSaveContactNumber
    case didTapSaveData
    case didTapDeleteContactNumber(String)

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

    case .binding:
        return .none
        
    case .didSelectSiteMapImage(let image):
        return uploadImage(image, environment: environment)

    case .didRemoveSiteMapImage:
        var event = state.event

        event.siteMapImageURL = nil
        return updateEvent(event: event, environment: environment)

    case .didTapSaveContactNumber:
        state.contactNumbers.append(.init(
            title: state.contactNumberTitleText,
            phoneNumber: state.contactNumberText,
            description: state.contactNumberDescriptionText
        ))
            
        state.contactNumberText = ""
        state.contactNumberDescriptionText = ""
        state.contactNumberTitleText = ""

        return .none

    case .didTapDeleteContactNumber(let id):
        state.contactNumbers.remove(id: id)
        return .none

    case .didTapSaveData:
        var event = state.event

        event.address = state.address
        event.contactNumbers = state.contactNumbers
        event.timeZone = state.timeZone
        event.latitude = state.latitude
        event.longitude = state.longitude

        return updateEvent(event: event, environment: environment)


    case .finishedUpdatingEvent:
        return .none

    case .uploadedImage(let url):

        var event = state.event
        event.siteMapImageURL = url

        return updateEvent(event: event, environment: environment)

    }
}
.binding()

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
