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

public struct ScheduleState: Equatable {
    public init(
        artists: IdentifiedArrayOf<Artist>,
        stages: IdentifiedArrayOf<Stage>,
        schedule: Schedule,
        selectedStage: Stage,
        event: Event,
        zoomAmount: CGFloat = 1,
        selectedDate: Date,
        cardToDisplay: ScheduleItem?,
        selectedArtistState: ArtistPageState?,
        selectedGroupSetState: GroupSetDetailState?,
        deviceOrientation: DeviceOrientation,
        currentTime: Date
    ) {
        self.artists = artists
        self.stages = stages
        self.event = event
        self.zoomAmount = zoomAmount
        self.selectedStage = selectedStage
        self.selectedDate = selectedDate
        self.schedule = schedule
        self.cardToDisplay = cardToDisplay
        self.selectedArtistState = selectedArtistState
        self.selectedGroupSetState = selectedGroupSetState
        self.deviceOrientation = deviceOrientation
        self.currentTime = currentTime
    }

    public var schedule: Schedule
    public let artists: IdentifiedArrayOf<Artist>
    public let stages: IdentifiedArrayOf<Stage>
    public var event: Event

    public var zoomAmount: CGFloat = 1
    @BindableState public var selectedStage: Stage
    public var selectedDate: Date
    public var deviceOrientation: DeviceOrientation

    public var cardToDisplay: ScheduleItem?
    @BindableState public var selectedArtistState: ArtistPageState?
    @BindableState public var selectedGroupSetState: GroupSetDetailState?

    public var currentTime: Date

    var shouldShowTimeIndicator: Bool {
        if event.dayStartsAtNoon {
            return Calendar.current.isDate(currentTime - 12.hours, inSameDayAs: selectedDate.startOfDay(dayStartsAtNoon: event.dayStartsAtNoon))
        } else {
            return Calendar.current.isDate(currentTime, inSameDayAs: selectedDate)
        }
    }
}

public enum ScheduleAction: BindableAction {
    case zoomed(CGFloat)
    case binding(_ action: BindingAction<ScheduleState>)
    case selectedDate(Date)

    case subscribeToDataPublishers
    case orientationPublisherUpdate(DeviceOrientation)
    case timePublisherUpdate(Date)

    case showAndHighlightCard(ScheduleItem)
    case highlightCard(ScheduleItem)
    case unHilightCard

    case didTapCard(ScheduleItem)

    case artistPageAction(ArtistPageAction)
    case groupSetDetailAction(GroupSetDetailAction)
}

public struct ScheduleEnvironment {
    var currentDate: () -> Date
    var timePublisher: AnyPublisher<Date, Never>

    public init(
        currentDate: @escaping () -> Date = Date.init,
        timePublisher: AnyPublisher<Date, Never> = Timer.publish(every: 1.seconds, on: RunLoop.main, in: .common).autoconnect().eraseToAnyPublisher()
    ) {
        self.currentDate = currentDate
        self.timePublisher = timePublisher
    }
}

public let scheduleReducer = Reducer<ScheduleState, ScheduleAction, ScheduleEnvironment>.combine(
    artistPageReducer.optional().pullback(
        state: \ScheduleState.selectedArtistState,
        action: /ScheduleAction.artistPageAction,
        environment: { _ in .init()}
    ),

    groupSetDetailReducer.optional().pullback(
        state: \ScheduleState.selectedGroupSetState,
        action: /ScheduleAction.groupSetDetailAction,
        environment: { _ in .init() }
    ),

    Reducer { state, action, environment in
        switch action {
        case .binding:
            return .none

        case .zoomed(let amount):
            state.zoomAmount = amount
            return .none

        case .selectedDate(let date):
            state.selectedDate = date
            return .none

        case .subscribeToDataPublishers:
            return Publishers.Merge(
                DeviceOrientation.deviceOrientationPublisher().map {
                    ScheduleAction.orientationPublisherUpdate($0)
                },
                environment.timePublisher.map {
                    ScheduleAction.timePublisherUpdate($0)
                }
            )
            .eraseToEffect()

        case .orientationPublisherUpdate(let orientation):
            state.deviceOrientation = orientation
            return .none

        case .timePublisherUpdate(let currentTime):
            state.currentTime = currentTime
            return .none

        case .showAndHighlightCard(let card):
            if let stage = state.stages[id: card.stageID] {
                state.selectedStage = stage
            }

            state.selectedDate = card.startTime.startOfDay(dayStartsAtNoon: state.event.dayStartsAtNoon)

            return .asyncTask {
                try! await Task.sleep(nanoseconds: 100_000_000)

                // Need to set cardToDisplay after a delay, otherwise the onChange and scrollTo combination won't work
                return .highlightCard(card)
            }
            .receive(on: DispatchQueue.main)
            .eraseToEffect()

        case .highlightCard(let card):
            state.cardToDisplay = card
            return Effect(value: .unHilightCard)
                .delay(for: 1, scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main.animation(.easeOut(duration: 1)))
                .eraseToEffect()

        case .unHilightCard:
            state.cardToDisplay = nil

            return .none

        case .didTapCard(let card):
            switch card.type {
            case .artistSet(let artistID):
                guard let artist = state.artists[id: artistID]  ?? state.artists.first else { return .none }

                state.selectedArtistState = .init(
                    artist: artist,
                    event: state.event,
                    setsForArtist: state.schedule.scheduleItemsForArtist(artist: artist),
                    stages: state.stages
                )

                return .none

            case .groupSet:
                guard let groupSet = state.schedule.itemFor(itemID: card.id) else { return.none }

                state.selectedGroupSetState = .init(
                    groupSet: groupSet,
                    event: state.event,
                    schedule: state.schedule,
                    artists: state.artists,
                    stages: state.stages
                )

                return .none
            }
        case .artistPageAction(.didTapArtistSet(let scheduleItem)):
            state.selectedArtistState = nil
            return Effect(value: .showAndHighlightCard(scheduleItem))

        case .groupSetDetailAction(.didTapScheduleItem(let scheduleItem)):
            state.selectedGroupSetState = nil
            return Effect(value: .showAndHighlightCard(scheduleItem))
            
        case .artistPageAction, .groupSetDetailAction:
            return .none
        }
    }
    .binding()
)


extension Store where State == ScheduleState, Action == ScheduleAction {
    static var testStore: Store<ScheduleState, ScheduleAction> {
        let time = Event.testData.festivalDates[0]
        return Store(
            initialState: .init(
                artists: Artist.testValues.asIdentifedArray,
                stages: Stage.testValues.asIdentifedArray,
                schedule: .init(),
                selectedStage: Stage.testValues[0],
                event: .testData,
                selectedDate: time,
                cardToDisplay: nil,
                selectedArtistState: nil,
                selectedGroupSetState: nil,
                deviceOrientation: .portrait,
                currentTime: Date()
            ),
            reducer: scheduleReducer,
            environment: .init()
        )
    }
}

public enum DeviceOrientation {
    case portrait
    case landscape

    static func deviceOrientationPublisher() -> AnyPublisher<DeviceOrientation, Never> {

        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { ($0.object as? UIDevice)?.orientation }
            .compactMap { deviceOrientation -> DeviceOrientation? in
                if deviceOrientation.isPortrait {
                    return .portrait
                } else if deviceOrientation.isLandscape {
                    return .landscape
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()

    }
}
