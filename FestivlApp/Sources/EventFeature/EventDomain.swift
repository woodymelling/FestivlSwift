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
import Kingfisher
import ArtistPageFeature
import GroupSetDetailFeature
import ScheduleFeature
import ComposableUserNotifications

public struct EventFeature: ReducerProtocol {
    public init() {}
    
    let artistService: () -> ArtistServiceProtocol = { ArtistService.shared }
    let stageService: () -> StageServiceProtocol = { StageService.shared }
    let artistSetService: () -> ScheduleServiceProtocol = { ScheduleService.shared }
    let userNotificationClient: () -> UserNotificationClient = { UserNotificationClient.live }
    
    @Dependency(\.date) var currentDate
    
    public struct State: Equatable {

        let isTestMode: Bool
        let isEventSpecificApplication: Bool

        var event: Event
        var artists: IdentifiedArrayOf<Artist> = .init()
        var stages: IdentifiedArrayOf<Stage> = .init()
        var schedule: Schedule = .init()

        var favoriteArtists: Set<ArtistID> = [] {
            didSet {
                UserDefaults.standard.set(Array(favoriteArtists), forKey: "favoriteArtists")
            }
        }

        // MARK: TabBarState
        @BindableState var selectedTab: Tab = .schedule

        // MARK: ArtistListState
        var artistListSearchText: String = ""

        // MARK: ScheduleState
        var scheduleSelectedStage: Stage = .testData
        var scheduleZoomAmount: CGFloat = 1
        var scheduleLastScaleValue: CGFloat = 1
        var scheduleSelectedDate: Date
        var scheduleFilteringFavorites = false
        var scheduleCardToDisplay: ScheduleItem?
        var scheduleSelectedArtistState: ArtistPage.State?
        var selectedGroupSetState: GroupSetDetail.State?
        var deviceOrientation: DeviceOrientation = .portrait
        var currentTime: Date = Date()

        @Storage(key: "hasDisplayedTutorialElements", defaultValue: false)
        var hasDisplayedTutorialElements: Bool
        var showingLandscapeTutorial = false
        var showingFilterTutorial = false

        // MARK: ExploreState
        var exploreArtists: IdentifiedArrayOf<Artist> = .init()
        var exploreSelectedArtistState: ArtistPage.State?

        // MARK: MoreState
        @Storage(key: "notificationsEnabled", defaultValue: false)
        var notificationsEnabled: Bool

        @Storage(key: "notificationsTimeBeforeSet", defaultValue: 15)
        var notificationTimeBeforeSet: Int

        var notificationsShowingNavigateToSettingsAlert: Bool = false

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
        var hasRunSetup = false

        public init(event: Event, isTestMode: Bool, isEventSpecificApplication: Bool) {
            self.event = event
            self.isTestMode = isTestMode
            self.isEventSpecificApplication = isEventSpecificApplication

            if let timeZone = event.timeZone, let timeZone = TimeZone(identifier: timeZone) {
                NSTimeZone.default = timeZone
            }

            self.scheduleSelectedDate = event.startDate.startOfDay(dayStartsAtNoon: event.dayStartsAtNoon)
        }
    }
    
    public enum Action {

        case onAppear
        case setUpWhenDataLoaded

        case userNotification(UserNotificationClient.Action)

        case favoriteArtistsPublisherUpdate(Set<ArtistID>)

        case artistsPublisherUpdate(IdentifiedArrayOf<Artist>)
        case preLoadArtistImages
        case finishedLoadingArtistImages

        case stagesPublisherUpdate(IdentifiedArrayOf<Stage>)
        case preLoadStageImages
        case finishedLoadingStageImages

        case artistSetsPublisherUpdate((artistSets: IdentifiedArrayOf<ArtistSet>, groupSets: IdentifiedArrayOf<GroupSet>))
        case tabBarAction(TabBar.Action)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return Effect.concatenate(

                    Publishers.Merge5(
                        artistService()
                            .artistsPublisher(eventID: state.event.id!)
                            .eraseErrorToPrint(errorSource: "ArtistServicePublisher")
                            .map { .artistsPublisherUpdate($0) },

                        stageService()
                            .stagesPublisher(eventID: state.event.id!)
                            .eraseErrorToPrint(errorSource: "StagesServicePublisher")
                            .map { .stagesPublisherUpdate($0) },

                        artistSetService()
                            .schedulePublisher(eventID: state.event.id!)
                            .eraseErrorToPrint(errorSource: "ArtistSetServicePublisher")
                            .map { .artistSetsPublisherUpdate($0) },

                        UserDefaults.standard.publisher(for: \.favoriteArtists)
                            .map {
                                .favoriteArtistsPublisherUpdate(Set($0))
                            },

                        userNotificationClient()
                            .delegate()
                            .map(Action.userNotification)
                        
                    ).eraseToEffect()

                )
                .eraseToEffect()


            case let .userNotification(.willPresentNotification(_, completion)):
                return .fireAndForget {
                    completion([.list, .banner, .sound])
                }

            case let .userNotification(.didReceiveResponse(response, completion)):


                if case .user(let action) = response {
                    print("ACTIONIDENTIFIER", response.actionIdentifier)
                    switch response.actionIdentifier {
                    case "GO_TO_SET_ACTION", UNNotificationDefaultActionIdentifier:
                        if let setID = action.notification.request.content.userInfo()["SET_ID"] as? String,
                           let scheduleItem = state.schedule.itemFor(itemID: setID) {
                            state.selectedTab = .schedule
                            return .concatenate(
                                Effect(value: .tabBarAction(.scheduleAction(.showAndHighlightCard(scheduleItem)))),
                                .fireAndForget { completion() }
                            )
                        }
                    default:
                        break
                    }
                }
                return .fireAndForget {
                    completion()
                }

            case .userNotification(.openSettingsForNotification):
                return .none

            case .favoriteArtistsPublisherUpdate(let favoriteArtists):
                if state.favoriteArtists != favoriteArtists {
                    state.favoriteArtists = favoriteArtists
                }

                return Effect(value: .tabBarAction(.moreAction(.notificationsAction(.regenerateNotifications()))))

                // MARK: Artists Loading
            case .artistsPublisherUpdate(let artists):
                state.artists = artists

                state.exploreArtists = artists
                    .filter { $0.imageURL != nil }
                    .shuffled()
                    .asIdentifedArray
                
                

                state.loadedArtists = true

                return .concatenate(
                    Effect(value: .preLoadArtistImages),
                    Effect(value: .setUpWhenDataLoaded)
                )

            case .preLoadArtistImages:

                let state = state
                return .task {
                    await ImageCacher.preFetchImage(urls: state.artists.compactMap { $0.imageURL })
                    return .finishedLoadingArtistImages
                }

            case .finishedLoadingArtistImages:

                return Effect(value: .setUpWhenDataLoaded)

                // MARK: Stages Loading
            case .stagesPublisherUpdate(let stages):
                state.stages = stages
                if !state.loadedStages {
                    state.scheduleSelectedStage = stages.first!
                }

                return Effect(value: .preLoadStageImages)

            case .preLoadStageImages:
                let state = state
                return .task {
                    await ImageCacher.preFetchImage(urls: state.stages.compactMap{ $0.iconImageURL })
                    return .finishedLoadingStageImages
                }

            case .finishedLoadingStageImages:
                state.loadedStages = true
                return Effect(value: .setUpWhenDataLoaded)

            case .artistSetsPublisherUpdate(let scheduleData):

                state.schedule = .init()

                for artistSet in scheduleData.artistSets {
                    state.schedule.insert(
                        for: artistSet.scheduleKey(dayStartsAtNoon: state.event.dayStartsAtNoon),
                        value: artistSet.asScheduleItem()
                    )
                }

                for groupSet in scheduleData.groupSets {
                    state.schedule.insert(
                        for: groupSet.scheduleKey(dayStartsAtNoon: state.event.dayStartsAtNoon),
                        value: groupSet.asScheduleItem()
                    )
                }

                state.loadedArtistSets = true
                return Effect(value: .setUpWhenDataLoaded)

            case .tabBarAction:
                return .none

            case .setUpWhenDataLoaded:
                guard state.eventLoaded && !state.hasRunSetup else { return .none }

                state.hasRunSetup = true

                let selectedDate: Date

                // Choose selected date based on now and event days
                if (state.event.startDate...state.event.endDate).contains(currentDate()) {
                    selectedDate = currentDate().startOfDay(dayStartsAtNoon: state.event.dayStartsAtNoon)
                } else {
                    selectedDate = state.event.startDate.startOfDay(dayStartsAtNoon: state.event.dayStartsAtNoon)
                }

                state.scheduleSelectedDate = selectedDate

                // Choose selected stage based on stages and sets
                let selectedStage = state.stages.first(where: { stage in
                    state.schedule[SchedulePageIdentifier(date: state.scheduleSelectedDate, stageID: stage.id!)]?.contains {
                        $0.isOnDate(selectedDate, dayStartsAtNoon: state.event.dayStartsAtNoon)
                    } ?? false
                })

                // TODO: What happens if there are no stages yet? Is that important
                state.scheduleSelectedStage = selectedStage ?? state.stages.first!
                
                UserDefaults.saveScheduleForWidget(schedule: state.schedule, stages: state.stages, festivalName: state.event.name)

                return .none
            }
        }
        
        Scope(state: \.self, action: /Action.tabBarAction) {
            TabBar()
        }
    }
}

extension ScheduleItemProtocol {
    func scheduleKey(dayStartsAtNoon: Bool) -> SchedulePageIdentifier {
        .init(date: startTime.startOfDay(dayStartsAtNoon: dayStartsAtNoon), stageID: stageID)
    }
}

extension UserDefaults {
    @objc dynamic var favoriteArtists: [ArtistID] {
        return stringArray(forKey: "favoriteArtists") ?? []
    }
    
    static func saveScheduleForWidget(
        schedule: Schedule,
        stages: IdentifiedArrayOf<Stage>,
        festivalName: String
    ) {
        
        UserDefaults(suiteName: "group.Festivl")?.set(festivalName, forKey: "activeFestivalName")
        
        if let data = try? JSONEncoder().encode(schedule) {
            UserDefaults(suiteName: "group.Festivl")?.set(data, forKey: "activeFestivalSchedule")
        }
        
    }
}


