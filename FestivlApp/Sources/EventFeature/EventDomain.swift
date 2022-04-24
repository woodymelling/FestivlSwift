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

public struct EventState: Equatable {

    let isTestMode: Bool

    var event: Event
    var artists: IdentifiedArrayOf<Artist> = .init()
    var stages: IdentifiedArrayOf<Stage> = .init()
    var schedule: Schedule = .init()

    //    @Storage(
    //        key: "favoriteArtists",
    //        defaultValue: [],
    //        transformation: .init(
    //            get: { Set($0) },
    //            set: { Array($0) }
    //        )
    //    )
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
    var scheduleSelectedArtistState: ArtistPageState?
    var selectedGroupSetState: GroupSetDetailState?
    var deviceOrientation: DeviceOrientation = .portrait
    var currentTime: Date = Date()

    // MARK: ExploreState
    var exploreArtists: IdentifiedArrayOf<Artist> = .init()
    var exploreSelectedArtistState: ArtistPageState?

    // MARK: MoreState
    @Storage(key: "notificationsEnabled", defaultValue: false)
    var notificationsEnabled: Bool

    @Storage(key: "notificationsTimeBeforeSet", defaultValue: 15)
    var notificationTimeBeforeSet: Int

    var notificatoinsShowingNavigateToSettingsAlert: Bool = false

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

    public init(event: Event, isTestMode: Bool) {
        self.event = event
        self.isTestMode = isTestMode

        self.scheduleSelectedDate = event.startDate.startOfDay(dayStartsAtNoon: event.dayStartsAtNoon)
    }
}

public enum EventAction {

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
    case tabBarAction(TabBarAction)
}

public struct EventEnvironment {
    public var artistService: () -> ArtistServiceProtocol
    public var stageService: () -> StageServiceProtocol
    public var artistSetService: () -> ScheduleServiceProtocol
    public var currentDate: () -> Date = { Date.now }
    var userNotificationClient: () -> UserNotificationClient = { UserNotificationClient.live }

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

extension ScheduleItemProtocol {
    func scheduleKey(dayStartsAtNoon: Bool) -> SchedulePageIdentifier {
        .init(date: startTime.startOfDay(dayStartsAtNoon: dayStartsAtNoon), stageID: stageID)
    }
}

public let eventReducer = Reducer.combine(
    Reducer<EventState, EventAction, EventEnvironment> { state, action, environment in
        switch action {
        case .onAppear:
            return Effect.concatenate(

                Publishers.Merge5(
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
                        .map { EventAction.artistSetsPublisherUpdate($0) },

                    UserDefaults.standard.publisher(for: \.favoriteArtists)
                        .map {
                            EventAction.favoriteArtistsPublisherUpdate(Set($0))
                        },

                    environment.userNotificationClient()
                        .delegate()
                        .map(EventAction.userNotification)
                ).eraseToEffect()

            )
            .eraseToEffect()


        case let .userNotification(.willPresentNotification(notification, completion)):
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
            
            return Effect(value: .preLoadArtistImages)

        case .preLoadArtistImages:

            return preloadArtistImages(artists: state.artists)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()

        case .finishedLoadingArtistImages:
            state.loadedArtists = true
            return Effect(value: .setUpWhenDataLoaded)

            // MARK: Stages Loading
        case .stagesPublisherUpdate(let stages):
            state.stages = stages
            if !state.loadedStages {
                state.scheduleSelectedStage = stages.first!
            }

            return Effect(value: .preLoadStageImages)

        case .preLoadStageImages:
            return preloadStageImages(stages: state.stages)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()

        case .finishedLoadingStageImages:
            state.loadedStages = true
            return Effect(value: .setUpWhenDataLoaded)

        case .artistSetsPublisherUpdate(let scheduleData):

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
            if (state.event.startDate...state.event.endDate).contains(environment.currentDate()) {
                selectedDate = environment.currentDate().startOfDay(dayStartsAtNoon: state.event.dayStartsAtNoon)
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

            return .none
        }
    },


    tabBarReducer.pullback(
        state: \.self,
        action: /EventAction.tabBarAction,
        environment: { _ in TabBarEnvironment() }
    )

)
//    .debug()

func preloadArtistImages(artists: IdentifiedArrayOf<Artist>) -> Effect<EventAction, Never> {
    return .asyncTask {
        await ImageCacher.preFetchImage(urls: artists.compactMap { $0.imageURL })
        return .finishedLoadingArtistImages
    }
}

func preloadStageImages(stages: IdentifiedArrayOf<Stage>) -> Effect<EventAction, Never> {
    return .asyncTask {
        await ImageCacher.preFetchImage(urls: stages.compactMap{ $0.iconImageURL })
        return .finishedLoadingStageImages
    }
}


extension UserDefaults {
    @objc dynamic var favoriteArtists: [ArtistID] {
        return stringArray(forKey: "favoriteArtists") ?? []
    }
}
