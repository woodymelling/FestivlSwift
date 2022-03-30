//
//  FestivlManagerEvent.swift
//
//
//  Created by Woody on 3/8/2022.
//

import ComposableArchitecture
import Models
import Services
import Combine
import CreateArtistFeature
import AddEditStageFeature
import AddEditArtistSetFeature

public struct FestivlManagerEventState: Equatable {
    public var event: Event

    var artists: IdentifiedArrayOf<Artist> = .init()
    var stages: IdentifiedArrayOf<Stage> = .init()
    var artistSets: IdentifiedArrayOf<ArtistSet> = .init()

    var eventLoaded: Bool {
        return loadedArtists && loadedStages && loadedArtistSets
    }

    var loadedArtists = false
    var loadedStages = false
    var loadedArtistSets = false

    // SidebarState:
    @BindableState var sidebarSelection: SidebarPage? = .artists

    // ArtistListState:
    var artistListSelectedArtist: Artist?
    var createArtistState: CreateArtistState?
    var isPresentingArtistDeleteConfirmation: Bool = false

    // StageListState:
    var stagesListSelectedStage: Stage?
    var addEditStageState: AddEditStageState?
    var isPresentingStageDeleteConfirmation: Bool = false

    // ScheduleState:
    var scheduleSelectedDate: Date
    var scheduleZoomAmount: CGFloat = 1
    var addEditArtistSetState: AddEditArtistSetState?

    var dashboardState: Self {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    
    public init(event: Event) {
        self.event = event
        self.scheduleSelectedDate = event.festivalDates.first!.startOfDay
    }
}

public enum FestivlManagerEventAction {
    case subscribeToDataPublishers

    case artistsPublisherUpdate(IdentifiedArrayOf<Artist>)
    case stagesPublisherUpdate(IdentifiedArrayOf<Stage>)
    case artistSetsPublisherUpdate(IdentifiedArrayOf<ArtistSet>)

    case dashboardAction(ManagerEventDashboardAction)
}

public struct FestivlManagerEventEnvironment {
    public var artistService: () -> ArtistServiceProtocol
    public var stageService: () -> StageServiceProtocol
    public var artistSetService: () -> ArtistSetServiceProtocol
    public var currentDate: () -> Date = { Date.now }

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

public let festivlManagerEventReducer = Reducer.combine(

    managerEventDashboardReducer.pullback(
        state: \.dashboardState,
        action: /FestivlManagerEventAction.dashboardAction,
        environment: { _ in
            .init()
        }
    ),

    Reducer<FestivlManagerEventState, FestivlManagerEventAction, FestivlManagerEventEnvironment> { state, action, environment in
        switch action {
        case .subscribeToDataPublishers:
            return Publishers.Merge3(
                environment.artistService()
                    .artistsPublisher(eventID: state.event.id!)
                    .eraseErrorToPrint(errorSource: "ArtistServicePublisher")
                    .map { FestivlManagerEventAction.artistsPublisherUpdate($0) },

                environment.stageService()
                    .stagesPublisher(eventID: state.event.id!)
                    .eraseErrorToPrint(errorSource: "StagesServicePublisher")
                    .map { FestivlManagerEventAction.stagesPublisherUpdate($0) },

                environment.artistSetService()
                    .artistSetPublisher(eventID: state.event.id!)
                    .eraseErrorToPrint(errorSource: "ArtistSetServicePublisher")
                    .map { FestivlManagerEventAction.artistSetsPublisherUpdate($0) }
            )
            .eraseToEffect()

        case .artistsPublisherUpdate(let artists):
            state.artists = artists
            state.loadedArtists = true
            return .none

        case .stagesPublisherUpdate(let stages):
            state.stages = stages
            state.loadedStages = true
            return .none

        case .artistSetsPublisherUpdate(let artistSets):
            state.artistSets = artistSets
            state.loadedArtistSets = true
            print("Artist Set COUNT: \(artistSets.count)")
            return .none

        case .dashboardAction:
            return .none
        }
    }
)
.debug()


