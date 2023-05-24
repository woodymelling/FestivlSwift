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
    
    @Dependency(\.userDefaults.eventID) var eventID
    @Dependency(\.eventDataClient) var eventDataClient
    @Dependency(\.date) var todaysDate
    @Dependency(\.userFavoritesClient) var userFavoritesClient
    @Dependency(\.internalPreviewClient) var internalPreviewClient

    
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
                        eventDataClient.getData(self.eventID),
                        userFavoritesClient.userFavoritesPublisher()
                    )
                    .values {
                        print("Received Data!")
                        await send(.dataUpdate(data, userFavorites))
                    }
                } catch: { _, _ in
                    print("Artist Page Loading error")
                }
            case .dataUpdate(let eventData, let userFavorites):
                
//                guard !eventData.schedule.isEmpty else { return .none }
                
                userFavoritesClient.updateScheduleData(eventData.schedule, eventData.artists, eventData.stages)
                
                let selectedDate: CalendarDate
                let selectedStage: Stage.ID
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
                    selectedStage = firstStageWithItems.id
                } else {
                    selectedStage = eventData.stages.first!.id
                }
                
                // Business Rule:
                // If the schedule is unpublished and the user hasn't unlocked it with the passkey show the comingSoon Screen
                let showComingSoonScreen = !(event.scheduleIsPublished || internalPreviewClient.internalPreviewsAreUnlocked(event.id))
                
                state.scheduleState = ScheduleFeature.State(
                    schedule: eventData.schedule,
                    artists: eventData.artists,
                    stages: eventData.stages,
                    event: eventData.event,
                    userFavorites: userFavorites,
                    selectedStage: selectedStage,
                    selectedDate: selectedDate,
                    filteringFavorites: state.scheduleState?.filteringFavorites ?? false,
                    cardToDisplay: state.scheduleState?.cardToDisplay,
                    destination: state.scheduleState?.destination,
                    showTutorialElements: state.scheduleState?.showTutorialElements ?? false,
                    showingLandscapeTutorial: state.scheduleState?.showingLandscapeTutorial ?? false,
                    showingFilterTutorial: state.scheduleState?.showingFilterTutorial ?? false,
                    showingComingSoonScreen: showComingSoonScreen
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
    @Dependency(\.userDefaults) var userDefaults //
    
    public struct State: Equatable {
        internal init(
            schedule: Schedule,
            artists: IdentifiedArrayOf<Artist>,
            stages: IdentifiedArrayOf<Stage>,
            event: Event,
            userFavorites: UserFavorites,
            selectedStage: Stage.ID,
            selectedDate: CalendarDate,
            deviceOrientation: DeviceOrientation = .portrait,
            filteringFavorites: Bool,
            cardToDisplay: ScheduleItem.ID?,
            destination: ScheduleFeature.Destination.State?,
            showTutorialElements: Bool,
            showingLandscapeTutorial: Bool,
            showingFilterTutorial: Bool,
            showingComingSoonScreen: Bool
        ) {
            self.schedule = schedule
            self.artists = artists
            self.stages = stages
            self.event = event
            self.userFavorites = userFavorites
            self.selectedStage = selectedStage
            self.selectedDate = selectedDate
            self.deviceOrientation = deviceOrientation
            self.filteringFavorites = filteringFavorites
            self.cardToDisplay = cardToDisplay
            self.destination = destination
            self.showTutorialElements = showTutorialElements
            self.showingLandscapeTutorial = showingLandscapeTutorial
            self.showingFilterTutorial = showingFilterTutorial
            self.showingComingSoonScreen = showingComingSoonScreen
        }
        
        @PresentationState var destination: Destination.State?

        var schedule: Schedule
        let artists: IdentifiedArrayOf<Artist>
        let stages: IdentifiedArrayOf<Stage>
        var event: Event
        var userFavorites: UserFavorites
        
        @BindingState public var selectedStage: Stage.ID
        @BindingState public var selectedDate: CalendarDate
        @BindingState public var filteringFavorites: Bool
        
        public var deviceOrientation: DeviceOrientation = .portrait

        public var cardToDisplay: ScheduleItem.ID?
        

        public var showTutorialElements: Bool
        @BindingState public var showingLandscapeTutorial: Bool
        @BindingState public var showingFilterTutorial: Bool
        
        
        public var showingComingSoonScreen: Bool
        

        var isFiltering: Bool {
            // For future filters
            return filteringFavorites
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

        case task
        case scheduleTutorial(ScheduleTutorialAction)

        case orientationPublisherUpdate(DeviceOrientation)

        case showAndHighlightCard(ScheduleItem.ID)
        case highlightCard(ScheduleItem)
        case unHighlightCard

        case didTapCard(ScheduleItem)

        case destination(PresentationAction<Destination.Action>)
        
        
        public enum ScheduleTutorialAction {
            case showLandscapeTutorial
            case hideLandscapeTutorial
            case showFilterTutorial
            case hideFilterTutorial
        }
    }
    
    public struct Destination: ReducerProtocol {
        public enum State: Equatable {
            case artist(ArtistDetail.State)
            case groupSet(GroupSetDetail.State)
        }
        
        public enum Action {
            case artist(ArtistDetail.Action)
            case groupSet(GroupSetDetail.Action)
        }
        
        public var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.artist, action: /Action.artist) {
                ArtistDetail()
            }
            
            Scope(state: /State.groupSet, action: /Action.groupSet) {
                GroupSetDetail()
            }
        }
    }
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .task:
                return .merge(
                    showFilterTutorialIfRequired(state: &state),
                    .run { send in
                        for await orientation in deviceOrientationPublisher.values {
                            await send(.orientationPublisherUpdate(orientation))
                        }
                    }
                )

            case let .scheduleTutorial(tutorialAction):
                
                switch tutorialAction {
                case .showLandscapeTutorial:
                    state.showingLandscapeTutorial = true
                case .hideLandscapeTutorial:
                    state.showingLandscapeTutorial = false
                case .showFilterTutorial:
                    state.showingFilterTutorial = true
                case .hideFilterTutorial:
                    state.showingFilterTutorial = false
                }
                
                return .none

            case .orientationPublisherUpdate(let orientation):
                state.deviceOrientation = orientation
                return .none

            case .showAndHighlightCard(let cardID):
                
                state.destination = nil
                
                guard let card = state.schedule[id: cardID] else {
                    XCTFail("Could not find scheduleItem with id: \(cardID)")
                    return .none
                }
                
                let schedulePage = card.schedulePageIdentifier(dayStartsAtNoon: state.event.dayStartsAtNoon, timeZone: state.event.timeZone)
                
                if let stage = state.stages[id: schedulePage.stageID] {
                    state.selectedStage = stage.id
                }

                state.selectedDate = schedulePage.date
                
                state.cardToDisplay = cardID

                return .run { send in
                    
                    try! await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
                         
                    await send(.unHighlightCard, animation: .easeOut(duration: 2))
                }

            case .highlightCard(let card):
                state.cardToDisplay = card.id
                return .none

            case .unHighlightCard:
                state.cardToDisplay = nil

                return .none

            case .didTapCard(let card):
                switch card.type {
                case .artistSet(let artistID):
                    guard let artist = state.artists[id: artistID] else { return .none }
                    
                    state.destination = .artist(
                        ArtistDetail.State(
                            artistID: artist.id,
                            artist: artist,
                            event: state.event,
                            schedule: state.schedule,
                            stages: state.stages,
                            isFavorite: false // TODO: Fix
                        )
                    )

                    return .none

                case .groupSet:
                    guard let groupSet = state.schedule[id: card.id] else { return.none }

                    state.destination = .groupSet(.init(groupSet: groupSet))

                    return .none
                }
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    func showFilterTutorialIfRequired(state: inout State) -> Effect<Action> {
        if state.showingComingSoonScreen || self.userDefaults.hasShownScheduleTutorial {
            return .none
        }
        
        self.userDefaults.hasShownScheduleTutorial = true

        return .run { send in
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            
            await send(.scheduleTutorial(.showLandscapeTutorial))
            try await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC)
            await send(.scheduleTutorial(.hideLandscapeTutorial))
            
            await send(.scheduleTutorial(.showFilterTutorial))
            try await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC)
            await send(.scheduleTutorial(.hideFilterTutorial))
        }
    }
}
