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
import SwiftUI
import ImageCache

public struct EventState: Equatable {
    var event: Event
    var artists: IdentifiedArrayOf<Artist> = .init()
    var stages: IdentifiedArrayOf<Stage> = .init()
    var artistSets: IdentifiedArrayOf<ArtistSet> = .init()
    var groupSets: IdentifiedArrayOf<GroupSet> = .init()

    // MARK: TabBarState
    @BindableState var selectedTab: Tab = .schedule

    // MARK: ArtistListState
    var artistListSearchText: String = ""

    // MARK: ScheduleState
    var scheduleSelectedStage: Stage = .testData
    var scheduleZoomAmount: CGFloat = 1
    var scheduleSelectedDate: Date
    var scheduleScrollAmount: CGPoint = .zero

    var eventLoaded: Bool {
        return loadedArtists && loadedStages && loadedArtistSets
    }

    var tabBarState: Self {
        get {
            return self
        }
        set {
            self = newValue
        }
    }


    var loadedArtists = false
    var loadedStages = false
    var loadedArtistSets = false

    public init(event: Event) {
        self.event = event

        self.scheduleSelectedDate = event.startDate.startOfDay(dayStartsAtNoon: event.dayStartsAtNoon)
    }
}

public enum EventAction {
    case preLoadArtistImages
    case subscribeToDataPublishers
    case setUpWhenDataLoaded

    case artistsPublisherUpdate(IdentifiedArrayOf<Artist>)
    case stagesPublisherUpdate(IdentifiedArrayOf<Stage>)
    case artistSetsPublisherUpdate((artistSets: IdentifiedArrayOf<ArtistSet>, groupSets: IdentifiedArrayOf<GroupSet>))
    case finishedLoadingArtistImages

    case tabBarAction(TabBarAction)
}

public struct EventEnvironment {
    public var artistService: () -> ArtistServiceProtocol
    public var stageService: () -> StageServiceProtocol
    public var artistSetService: () -> ScheduleServiceProtocol
    public var currentDate: () -> Date = { Date.now }

    public init(
        artistService: @escaping () -> ArtistServiceProtocol = { ArtistService.shared },
        stageService: @escaping () -> StageServiceProtocol = { StageService.shared },
        artistSetService: @escaping () -> ScheduleServiceProtocol = { ScheduleService.shared }
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
                    .schedulePublisher(eventID: state.event.id!)
                    .eraseErrorToPrint(errorSource: "ArtistSetServicePublisher")
                    .map { EventAction.artistSetsPublisherUpdate($0) }
            )
            .eraseToEffect()

        case .artistsPublisherUpdate(let artists):
            state.artists = artists
            return Effect(value: .preLoadArtistImages)

        case .preLoadArtistImages:

            return preloadArtistImages(artists: state.artists)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()

        case .finishedLoadingArtistImages:
            state.loadedArtists = true
            return Effect(value: .setUpWhenDataLoaded)

        case .stagesPublisherUpdate(let stages):
            state.stages = stages
            if !state.loadedStages {
                state.scheduleSelectedStage = stages.first!
            }
            state.loadedStages = true
            return Effect(value: .setUpWhenDataLoaded)

        case .artistSetsPublisherUpdate(let schedule):
            state.artistSets = schedule.artistSets
            state.groupSets = schedule.groupSets
            state.loadedArtistSets = true
            return Effect(value: .setUpWhenDataLoaded)

        case .tabBarAction:
            return .none

        case .setUpWhenDataLoaded:
            guard state.eventLoaded else { return .none }

            let selectedDate: Date

            // Choose selected date based on now and event days
            if (state.event.startDate...state.event.endDate).contains(environment.currentDate()) {
                selectedDate = environment.currentDate().startOfDay(dayStartsAtNoon: state.event.dayStartsAtNoon)
            } else {
                selectedDate = state.event.startDate.startOfDay(dayStartsAtNoon: state.event.dayStartsAtNoon)
            }

            state.scheduleSelectedDate = selectedDate

            // Choose selected stage based on stages and sets

            // OPTIMIZATION POINT
            let selectedStage = state.stages.first(where: { stage in
                state.artistSets.contains {
                    $0.isOnDate(selectedDate, dayStartsAtNoon: state.event.dayStartsAtNoon)
                }
            })

            // TODO: What happens if there are no stages yet? Is that important
            state.scheduleSelectedStage = selectedStage ?? state.stages.first!

            return .none
        }
    },


    tabBarReducer.pullback(
        state: \.self,
        action: /EventAction.tabBarAction,
        environment: { _ in TabBarEnvironment() }
    )

)
    .debug()

func preloadArtistImages(artists: IdentifiedArrayOf<Artist>) -> Effect<EventAction, Never> {
    return .asyncTask {
        return .finishedLoadingArtistImages
        await withTaskGroup(of: Void.self) { group in
            for artist in artists.reversed() {
                if let url = artist.imageURL {
                    group.addTask {
                        await ImageCache.shared.loadAndStoreImage(url: url, size: .square(60))
                        print("Loaded Image For:", artist.name)
                    }
                }
            }

            await group.waitForAll()
        }
        return .finishedLoadingArtistImages
    }
}
