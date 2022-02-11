//
//  ArtistList.swift
//
//
//  Created by Woody on 2/9/2022.
//

import ComposableArchitecture
import Models
import Utilities

extension Artist: Searchable {
    public var searchTerms: [String] {
        [name]
    }
}

public struct ArtistListState: Equatable {
    var artists: [Artist]
    @BindableState var searchText: String = ""

    public init(artists: [Artist] = []) {
        self.artists = artists
    }
}

public enum ArtistListAction: BindableAction {
    case binding(_ action: BindingAction<ArtistListState>)
}

public struct ArtistListEnvironment {
    public init() { }
}

public let artistListReducer = Reducer<ArtistListState, ArtistListAction, ArtistListEnvironment> { state, action, _ in
    switch action {
    case .binding:
        return .none
    }
}
.binding()
