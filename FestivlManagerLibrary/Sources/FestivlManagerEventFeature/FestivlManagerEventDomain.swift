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
import AddEditEventFeature
import ManagerArtistsFeature
import EventDataFeature

public struct FestivlManagerEventState: Equatable {
    public var event: Event

    var artists: IdentifiedArrayOf<Artist> = .init()
    var stages: IdentifiedArrayOf<Stage> = .init()
    var artistSets: IdentifiedArrayOf<ArtistSet> = .init()
    var groupSets: IdentifiedArrayOf<GroupSet> = .init()

    var eventLoaded: Bool {
        return loadedArtists && loadedStages && loadedArtistSets
    }

    var loadedArtists = false
    var loadedStages = false
    var loadedArtistSets = false

    // SidebarState:
    @BindableState var sidebarSelection: SidebarPage? = .schedule
    @BindableState var editEventState: AddEditEventState?

    // ArtistListState:
    var artistListSelectedArtist: Artist?
    var createArtistState: CreateArtistState?
    var isPresentingArtistDeleteConfirmation: Bool = false
    var artistBulkAddState: BulkAddState?
    var artistListSearchText: String = ""

    // StageListState:
    var stagesListSelectedStage: Stage?
    var addEditStageState: AddEditStageState?
    var isPresentingStageDeleteConfirmation: Bool = false

    // ScheduleState:
    var scheduleSelectedDate: Date
    var scheduleZoomAmount: CGFloat = 1
    var addEditArtistSetState: AddEditArtistSetState?
    var scheduleArtistSearchText = ""

    

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
        self.scheduleSelectedDate = event.festivalDates.first!.startOfDay(dayStartsAtNoon: event.dayStartsAtNoon)
    }
}

public enum FestivlManagerEventAction {
    case subscribeToDataPublishers

    case artistsPublisherUpdate(IdentifiedArrayOf<Artist>)
    case stagesPublisherUpdate(IdentifiedArrayOf<Stage>)
    case artistSetsPublisherUpdate((artistSets: IdentifiedArrayOf<ArtistSet>, groupSets: IdentifiedArrayOf<GroupSet>))

    case dashboardAction(ManagerEventDashboardAction)
}

public struct FestivlManagerEventEnvironment {
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
                    .schedulePublisher(eventID: state.event.id!)
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

        case .artistSetsPublisherUpdate(let sets):
            state.artistSets = sets.artistSets
            state.groupSets = sets.groupSets
            state.loadedArtistSets = true

            return .none

        case .dashboardAction:
            return .none
        }
    }
)
//.debug()


