//
//  Event.swift
//
//
//  Created by Woody on 2/13/2022.
//

import ComposableArchitecture
import Models
import Services
import Combine
import IdentifiedCollections
import Utilities
import TabBarFeature

public struct EventState: Equatable {
    var event: Event
    var artists: IdentifiedArrayOf<Artist> = .init()
    var stages: IdentifiedArrayOf<Stage> = .init()
    var artistSets: IdentifiedArrayOf<ArtistSet> = .init()

    // MARK: TabBarState
    var selectedTab: Tab = .schedule

    // MARK: ArtistListState
    var artistListSearchText: String = ""

    var tabBarState: TabBarState {
        get {
            TabBarState(
                event: event,
                artists: artists,
                stages: stages,
                artistSets: artistSets,
                selectedTab: selectedTab,
                artistListSearchText: artistListSearchText
            )
        }

        set {
            self.selectedTab = newValue.selectedTab
            self.artists = newValue.artists
            self.event = newValue.event
            self.stages = newValue.stages
            self.artistSets = newValue.artistSets
            self.artistListSearchText = newValue.artistsListSearchText
        }
    }

    public init(event: Event) {
        self.event = event
    }
}

public enum EventAction {
    case subscribeToDataPublishers

    case artistsPublisherUpdate(IdentifiedArrayOf<Artist>)
    case stagesPublisherUpdate(IdentifiedArrayOf<Stage>)
    case artistSetsPublisherUpdate(IdentifiedArrayOf<ArtistSet>)

    case tabBarAction(TabBarAction)
}

public struct EventEnvironment {
    public var artistService: () -> ArtistServiceProtocol
    public var stageService: () -> StageServiceProtocol
    public var artistSetService: () -> ArtistSetServiceProtocol

    public init(
        artistService: @escaping () -> ArtistServiceProtocol = { ArtistService.shared },
        stageService: @escaping () -> StageServiceProtocol = { StageService.shared },
        artistSetService: @escaping () -> ArtistSetServiceProtocol = { ArtistSetService.shared }
    ) {
        self.artistService = artistService
        self.stageService = stageService
        self.artistSetService = artistSetService
    }
}

public let eventReducer = Reducer.combine(
    Reducer<EventState, EventAction, EventEnvironment> { state, action, environment in
        switch action {
        case .subscribeToDataPublishers:
            return Publishers.Merge3(
                environment.artistService()
                    .artistsPublisher(eventID: state.event.id!)
                    .eraseErrorToPrint(errorSource: "ArtistServicePublisher")
                    .map { EventAction.artistsPublisherUpdate($0) },

                environment.stageService()
                    .stagesPublisher(eventID: state.event.id!)
                    .eraseErrorToPrint(errorSource: "StagesServicePublisher")
                    .map { EventAction.stagesPublisherUpdate($0) },

                environment.artistSetService()
                    .artistSetPublisher(eventID: state.event.id!)
                    .eraseErrorToPrint(errorSource: "ArtistSetServicePublisher")
                    .map { EventAction.artistSetsPublisherUpdate($0) }
            )
            .eraseToEffect()

        case .artistsPublisherUpdate(let artists):
            state.artists = artists
            return .none
        case .stagesPublisherUpdate(let stages):
            state.stages = stages
            return .none
        case .artistSetsPublisherUpdate(let artistSets):
            state.artistSets = artistSets
            return .none
        case .tabBarAction:
            return .none
        }
    },


    tabBarReducer.pullback(
        state: \EventState.tabBarState,
        action: /EventAction.tabBarAction,
        environment: { _ in TabBarEnvironment() }
    )

)

