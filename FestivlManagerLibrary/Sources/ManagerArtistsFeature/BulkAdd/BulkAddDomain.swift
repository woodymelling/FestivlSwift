//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/9/22.
//

import Foundation
import ComposableArchitecture
import Models
import Services

public struct BulkAddState: Equatable, Identifiable {
    public let id = UUID()
    var eventID: String


    var loading = false
    @BindableState var text = ""
    @BindableState var shouldAdjustCapitalization = false
    @BindableState var seperator = ","
}

public enum BulkAddAction: BindableAction {
    case binding(_ action: BindingAction<BulkAddState>)
    case saveButtonPressed
    case cancelButtonPressed
    case finishedUploadingArtists

    case closeModal
}

struct BulkAddEnvironment {
    let artistService: () -> ArtistServiceProtocol

    init(artistService: @escaping () -> ArtistServiceProtocol = { ArtistService.shared }) {
        self.artistService = artistService
    }
}

let bulkAddReducer = Reducer<BulkAddState, BulkAddAction, BulkAddEnvironment> { state, action, environment in

    switch action {
    case .binding(\.$seperator):
        state.seperator = String(state.seperator.first ?? ",")
        return .none
    case .binding:
        return .none

    case .saveButtonPressed:
        state.loading = true

        return createArtists(
            list: state.text,
            eventID: state.eventID,
            environment: environment,
            shouldAdjustCapitalization: state.shouldAdjustCapitalization,
            seperator: state.seperator.first ?? ","
        )

    case .finishedUploadingArtists:
        return Effect(value: .closeModal)
        
    case .cancelButtonPressed:
        return Effect(value: .saveButtonPressed)

    case .closeModal:
        return .none
    }
}
.binding()


private func createArtists(list: String, eventID: String, environment: BulkAddEnvironment, shouldAdjustCapitalization: Bool, seperator: Character) -> Effect<BulkAddAction, Never> {
    let artistNames: [String] = list
        .split(whereSeparator: { $0 == seperator || $0.isNewline })
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .map {
            if shouldAdjustCapitalization {
                return $0.lowercased().capitalized
            } else {
                return $0
            }
        }

    return .asyncTask {
        await withTaskGroup(of: Void.self) { group in
            for name in artistNames {
                group.addTask {
                    let artist = Artist(name: name)
                    do {
                        _ = try await environment.artistService().createArtist(artist: artist, eventID: eventID)
                    } catch {
                        print(error)
                    }
                }
            }
        }

        return .finishedUploadingArtists
    }
    .receive(on: DispatchQueue.main)
    .eraseToEffect()
}
