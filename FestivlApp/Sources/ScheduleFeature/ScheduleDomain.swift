//
//  Schedule.swift
//
//
//  Created by Woody on 2/17/2022.
//

import ComposableArchitecture
import CoreGraphics
import Models
import ArtistPageFeature
import GroupSetDetailFeature
import Combine
import SwiftUI
import Utilities
import FestivlDependencies

public struct ScheduleLoadingFeature: ReducerProtocol {
    
    public init() {}
    
    @Dependency(\.eventID) var eventID
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.date) var todaysDate
    @Dependency(\.userFavoritesClient) var userFavoritesClient
    
    public struct State: Equatable {
        
        public init() {}
        
        var scheduleState: ScheduleFeature.State?
    }
    
    public enum Action {
        case task
        case dataUpdate(EventData, UserFavorites)
        
        case scheduleAction(ScheduleFeature.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for try await (data, userFavorites) in Publishers.CombineLatest(
                        eventDataClient.getData(eventID.value),
                        userFavoritesClient.userFavoritesPublisher()
                    ).values {
                        await send(.dataUpdate(data, userFavorites))
                    }
                } catch: { _, _ in
                    print("Artist Page Loading error")
                }
            case .dataUpdate(let eventData, let userFavorites):
                
                guard !eventData.schedule.isEmpty else { return .none }
                
                userFavoritesClient.updateScheduleData(eventData.schedule, eventData.artists, eventData.stages)
                
                let selectedDate: CalendarDate
                let selectedStage: Stage
                let event = eventData.event
                
                // This check chooses the correct date for when the app is opened
                if let currentlySelectedDate = state.scheduleState?.selectedDate {
                    selectedDate = currentlySelectedDate
                } else if CalendarDate.today.isWithin(rhs: event.startDate, lhs: event.endDate) { // TODO: Get from reducer
                    selectedDate = CalendarDate(date: todaysDate())
                } else {
                    selectedDate = event.startDate
                }
                
                // This check chooses the correct stage for when the app is opened
                if let currentlySelectedStage = state.scheduleState?.selectedStage {
                    selectedStage = currentlySelectedStage
                } else if let firstStageWithItems = firstStageWithItems(
                    onDate: selectedDate,
                    stages: eventData.stages,
                    schedule: eventData.schedule
                ) {
                    selectedStage = firstStageWithItems
                } else {
                    selectedStage = eventData.stages.first!
                }
            
                state.scheduleState = .init(
                    schedule: eventData.schedule,
                    artists: eventData.artists,
                    stages: eventData.stages,
                    event: eventData.event,
                    userFavorites: userFavorites,
                    selectedStage: selectedStage,
                    selectedDate: selectedDate
                )
                return .none
                
            case .scheduleAction:
                return .none
            }
        }
        .ifLet(\.scheduleState, action: /Action.scheduleAction) {
            ScheduleFeature()
        }
    }
    
    func firstStageWithItems(
        onDate selectedDate: CalendarDate,
        stages: IdentifiedArrayOf<Stage>,
        schedule: Schedule
    ) -> Stage? {
        return stages.first { stage in
            !schedule[schedulePage: .init(date: selectedDate, stageID: stage.id)].isEmpty
        }
    }
}

public struct ScheduleFeature: ReducerProtocol {
    
    @Dependency(\.deviceOrientationPublisher) var deviceOrientationPublisher
    
    public struct State: Equatable {

        public var schedule: Schedule
        public let artists: IdentifiedArrayOf<Artist>
        public let stages: IdentifiedArrayOf<Stage>
        public var event: Event
        var userFavorites: UserFavorites
        
        @BindingState public var selectedStage: Stage
        public var selectedDate: CalendarDate
        
        public var zoomAmount: CGFloat = 1
        public var lastScaleValue: CGFloat = 1
        
        public var deviceOrientation: DeviceOrientation = .portrait
        @BindingState public var filteringFavorites: Bool = false

        public var cardToDisplay: ScheduleItem?
        @BindingState public var selectedArtistState: ArtistPage.State?
        @BindingState public var selectedGroupSetState: GroupSetDetail.State?

        public var hasShownTutorialElements: Bool = true
        @BindingState public var showingLandscapeTutorial: Bool = false
        @BindingState public var showingFilterTutorial: Bool = false
        

        var isFiltering: Bool {
            // For future filters
            return filteringFavorites
        }

        var shouldShowTimeIndicator: Bool {
            return true
        }
    }
    
    static func isFavorited(_ item: ScheduleItem, favorites: UserFavorites) -> Bool {
        switch item.type {
        case .artistSet(let artistID):
            return favorites.contains(artistID)
        case .groupSet(let artistIDs):
            // Group set is favorited if one of the artists is favorited
            return artistIDs.contains { favorites.contains($0) }
        }
    }
    
    public enum Action: BindableAction {
        case binding(_ action: BindingAction<State>)
        case selectedDate(CalendarDate)

        case zoomed(CGFloat)
        case finishedZooming

        case task
        case showTutorialElements
        case hideLandscapeTutorial
        case showFilterTutorial
        case hideFilterTutorial

        case subscribeToDataPublishers
        case orientationPublisherUpdate(DeviceOrientation)

        case showAndHighlightCard(ScheduleItem)
        case highlightCard(ScheduleItem)
        case unHighlightCard

        case didTapCard(ScheduleItem)

        case artistPageAction(ArtistPage.Action)
        case groupSetDetailAction(GroupSetDetail.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .task:
                return .run { send in
                    await send(.subscribeToDataPublishers)
                    
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                    
                    await send(.showTutorialElements)
                    
                }


            case .showTutorialElements:

                guard !state.hasShownTutorialElements else { return .none }

                state.showingLandscapeTutorial = true
                state.hasShownTutorialElements = true
                
                return .run { send in
                    try await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC)
                    await send(.hideLandscapeTutorial)
                    await send(.showFilterTutorial)
                    try await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC)
                    await send(.hideFilterTutorial)
                }

            case .hideLandscapeTutorial:
                state.showingLandscapeTutorial = false
                return .none

            case .showFilterTutorial:
                state.showingFilterTutorial = true
                return .none

            case .hideFilterTutorial:
                state.showingFilterTutorial = false
                return .none

            case .zoomed(let val):
                let delta = val / state.lastScaleValue
                state.lastScaleValue = val
                state.zoomAmount = (state.zoomAmount * delta).bounded(min: 0.5, max: 3)
                return .none

            case .finishedZooming:
                state.lastScaleValue = 1
                return .none

            case .selectedDate(let date):
                state.selectedDate = date
                return .none

            case .subscribeToDataPublishers:
                return deviceOrientationPublisher.map {
                    Action.orientationPublisherUpdate($0)
                }
                .eraseToEffect()

            case .orientationPublisherUpdate(let orientation):
                state.deviceOrientation = orientation
                return .none

            case .showAndHighlightCard(let card):
                
                let schedulePage = card.schedulePageIdentifier(dayStartsAtNoon: state.event.dayStartsAtNoon)
                
                if let stage = state.stages[id: schedulePage.stageID] {
                    state.selectedStage = stage
                }

                state.selectedDate = schedulePage.date

                return .run { send in
                    try await Task.sleep(nanoseconds: 100_000_000)

                    // Need to set cardToDisplay after a delay, otherwise the onChange and scrollTo combination won't work
                    await send(.highlightCard(card))
                         
                    await send(.unHighlightCard, animation: .easeOut(duration: 2))
                }

            case .highlightCard(let card):
                state.cardToDisplay = card
                return .none

            case .unHighlightCard:
                state.cardToDisplay = nil

                return .none

            case .didTapCard(let card):
                switch card.type {
                case .artistSet(let artistID):
                    guard let artist = state.artists[id: artistID] else { return .none }

                    state.selectedArtistState = .init(
                        artistID: artist.id,
                        artist: artist,
                        event: state.event,
                        schedule: state.schedule,
                        stages: state.stages,
                        isFavorite: false // TODO: Fix
                    )

                    return .none

                case .groupSet:
                    guard let groupSet = state.schedule[id: card.id] else { return.none }

                    state.selectedGroupSetState = .init(groupSet: groupSet)

                    return .none
                }
                
            case .artistPageAction(.didTapScheduleItem(let scheduleItem)):
                state.selectedArtistState = nil
                return .task { .showAndHighlightCard(scheduleItem) }

            case .groupSetDetailAction(.didTapScheduleItem(let scheduleItem)):
                state.selectedGroupSetState = nil
                return .task { .showAndHighlightCard(scheduleItem) }
                
            case .artistPageAction, .groupSetDetailAction:
                return .none
            }
        }
        .ifLet(\.selectedArtistState, action: /Action.artistPageAction) {
            ArtistPage()
        }
        .ifLet(\.selectedGroupSetState, action: /Action.groupSetDetailAction) {
            GroupSetDetail()
        }
    }
}
