//
// ManagerArtistsDomain.swift
//
//
//  Created by Woody on 3/10/2022.
//

import ComposableArchitecture
import Models

public struct ManagerArtistsState: Equatable {
    public init(
        artists: IdentifiedArrayOf<Artist>,
        selectedArtist: Artist?,
        isShowingAddArtist: Bool
    ) {
        self.artists = artists
        self.selectedArtist = selectedArtist
        self.isShowingAddArtist = isShowingAddArtist
    }

    public var artists: IdentifiedArrayOf<Artist>

    @BindableState public var selectedArtist: Artist?
    @BindableState public var isShowingAddArtist: Bool
}

public enum ManagerArtistsAction: BindableAction {
    case binding(_ action: BindingAction<ManagerArtistsState>)
    case addArtistButtonPressed
}

public struct ManagerArtistsEnvironment {
    public init() {}
}

public let managerArtistsReducer = Reducer<ManagerArtistsState, ManagerArtistsAction, ManagerArtistsEnvironment> { state, action, _ in
    switch action {
    case .binding:
        return .none
    case .addArtistButtonPressed:
        state.isShowingAddArtist = true
        return .none
    }
}
.binding()
