//
// AddEditStageDomain.swift
//
//
//  Created by Woody on 3/22/2022.
//

import ComposableArchitecture
import Models
import SwiftUI
import Components
import Services

enum Mode: Equatable {
    case create
    case edit(originalStage: Stage)

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
            return "Create Stage"
        case let .edit(originalStage):
            return "Update Stage (\(originalStage.name))"
        }
    }
}

public struct AddEditStageState: Equatable, Identifiable {
    public var id: UUID = UUID.init()

    var mode: Mode
    var eventID: EventID

    @BindableState var name: String = ""
    @BindableState var symbol: String = ""
    @BindableState var color: Color = StageColors.defaults.randomElement()!
    @BindableState var image: NSImage?
    @BindableState var selectedImage: NSImage?
    var editingImageURL: URL?

    var loading = false
    var didUpdateImage = false
    var hasLoadedImage = false

    var stageCount: Int

    public init(eventID: EventID, stageCount: Int) {
        self.mode = .create
        self.eventID = eventID
        self.stageCount = stageCount
    }

    public init(editing stage: Stage, eventID: EventID, stageCount: Int) {
        self.mode = .edit(originalStage: stage)
        self.eventID = eventID

        self.name = stage.name
        self.symbol = stage.symbol
        self.color = stage.color
        self.editingImageURL = stage.iconImageURL
        self.stageCount = stageCount
    }
}

public enum AddEditStageAction: BindableAction {
    case binding(_ action: BindingAction<AddEditStageState>)
    case loadImageIfRequired
    case imageLoaded(Result<NSImage?, NSError>)
    case saveButtonPressed
    case cancelButtonPressed
    case finishedUploadingStage(Stage)
    case closeModal(navigateTo: Stage?)
}

public struct AddEditStageEnvironment {
    let stageService: () -> StageServiceProtocol
    let imageService: () -> ImageServiceProtocol
    let uuid: () -> UUID
    public init(
        stageService: @escaping () -> StageServiceProtocol = { StageService.shared },
        imageService: @escaping () -> ImageServiceProtocol = { ImageService.shared },
        uuid: @escaping () -> UUID = UUID.init

    ) {
        self.stageService = stageService
        self.imageService = imageService
        self.uuid = uuid
    }
}

public let addEditStageReducer = Reducer<AddEditStageState, AddEditStageAction, AddEditStageEnvironment> { state, action, environment in
    switch action {

    case .binding(\.$image):
        state.didUpdateImage = true
        return .none

    case .binding(\.$name):
        // Make the symbol be the first letter of the stage name
        state.symbol = String(state.name.prefix(1))

        return .none

    case .binding(\.$symbol):
        // Business Rule:
        // Symbol can be two letters max
        state.symbol = String(state.symbol.prefix(2))
        return .none

    case .binding:
        return .none

    case .loadImageIfRequired:
        guard !state.hasLoadedImage else { return .none }
        state.hasLoadedImage = true

        if let imageURL = state.editingImageURL {
            state.loading = true
            return Effect.asyncTask {
                await NSImage.fromURL(url: imageURL)
            }
            .map { result in
                AddEditStageAction.imageLoaded(result)
            }
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
        } else {
            return .none
        }

    case .imageLoaded(let imageResult):
        state.loading = false
        if case let .success(image) = imageResult, let image = image {
            state.image = image
            state.selectedImage = image
        }

        return .none

    case .saveButtonPressed:
        state.loading = true
        
        

        var stage = Stage(
            name: state.name,
            symbol: state.symbol,
            colorString: state.color.hexString,
            iconImageURL: nil,
            sortIndex: state.stageCount
        )

        return uploadStage(
            stage: stage,
            image: state.image,
            eventID: state.eventID,
            didUpdateImage: state.didUpdateImage,
            mode: state.mode,
            environment: environment
        )

    case .cancelButtonPressed:
        return .init(value: .closeModal(navigateTo: nil))

    case .finishedUploadingStage(let stage):
        state.loading = false
        return .init(value: .closeModal(navigateTo: stage))

    case .closeModal:
        return .none
    }

}
.binding()

private func uploadStage(
    stage: Stage,
    image: NSImage?,
    eventID: EventID,
    didUpdateImage: Bool,
    mode: Mode,
    environment: AddEditStageEnvironment
) -> Effect<AddEditStageAction, Never> {
    var stage = stage

    return Effect.asyncTask {
        if let image = image, didUpdateImage {
            let imageURL = try await environment.imageService().uploadImage(image, fileName: environment.uuid().uuidString)
            stage.iconImageURL = imageURL
        }

        switch mode {
        case .create:
            stage = try await environment.stageService().createStage(
                stage: stage, eventID: eventID
            )
        case .edit(let originalStage):
            stage.id = originalStage.id
            try await environment.stageService().updateStage(stage: stage, eventID: eventID)
        }
    }
    .receive(on: DispatchQueue.main)
    .map { _ in
        AddEditStageAction.finishedUploadingStage(stage)

    }
    .eraseToEffect()
}
