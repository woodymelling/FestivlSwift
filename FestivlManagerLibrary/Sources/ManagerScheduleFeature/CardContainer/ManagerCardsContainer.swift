//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 3/29/22.
//

import SwiftUI
import ComposableArchitecture
import Models
import UniformTypeIdentifiers
import Utilities

struct ManagerCardsContainerView: View {
    let store: Store<ManagerScheduleState, ManagerScheduleAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geo in

                ForEachStore(
                    self.store.scope(
                        state: \.displayedArtistSetCardStates,
                        action: ManagerScheduleAction.artistSetCard(id:action:)
                    )
                ) { artistSetStore in
                    WithViewStore(artistSetStore) { artistSetViewStore in
                        let artistSet = artistSetViewStore.artistSet
                        let size = sizeForSet(
                            artistSet,
                            containerSize: geo.size,
                            stageCount: viewStore.stages.count
                        )
                        // Placement works by center of the view, move it to the top left
                        let offset = CGSize(width: size.width / 2, height: size.height / 2)

                        ArtistSetCardView(
                            store: artistSetStore,
                            viewHeight: geo.size.height,
                            selectedDate: viewStore.selectedDate
                        )
                        .frame(size: size)
                        .position(
                            x: xPlacementForSet(
                                artistSet,
                                containerWidth: geo.size.width,
                                stages: viewStore.stages
                            ),
                            y: dateToY(
                                artistSet.startTime,
                                containerHeight: geo.size.height,
                                dayStartsAtNoon: viewStore.event.dayStartsAtNoon
                            )
                        )
                        .offset(offset)
                        .onDrag {
                            return artistSet.itemProvider
                        }
                    }
                }
                .onDrop(
                    of: [ArtistSet.typeIdentifier],
                    delegate: ScheduleDropDelegate(
                        geometry: geo,
                        viewStore: viewStore
                    )
                )

            }
            .coordinateSpace(name: "ScheduleTimeline")
            .border(.green)
        }

    }
}


/// Get the frame size for an artistSet in a specfic container
private func sizeForSet(
    _ artistSet: ArtistSet,
    containerSize: CGSize,
    stageCount: Int
) -> CGSize {
    let width = containerSize.width / CGFloat(stageCount) - 1

    let setLengthInSeconds = artistSet.endTime.timeIntervalSince(artistSet.startTime)
    let height = secondsToY(
        Int(setLengthInSeconds),
        containerHeight: containerSize.height
    )
    return CGSize(width: width, height: height)
}

/// Get the X placement for set in a container of a specifc width
func xPlacementForSet(
    _ artistSet: ArtistSet,
    containerWidth: CGFloat,
    stages: IdentifiedArrayOf<Stage>
) -> CGFloat {
    return (containerWidth / CGFloat(stages.count)) * CGFloat(stages[id: artistSet.stageID]!.sortIndex)
}

/// Get the y placement for a set in a container of a specific height
func yPlacementForSet(
    _ artistSet: ArtistSet,
    containerHeight: CGFloat,
    dayStartsAtNoon: Bool
) -> CGFloat {
    return dateToY(
        artistSet.startTime,
        containerHeight: containerHeight,
        dayStartsAtNoon: dayStartsAtNoon
    )
}

/// Get the the y placement for a date in a container of a specific height
func dateToY(
    _ date: Date,
    containerHeight: CGFloat,
    dayStartsAtNoon: Bool
) -> CGFloat {

    let calendar = Calendar.autoupdatingCurrent

    var hoursIntoTheDay = calendar.component(.hour, from: date)
    let minutesIntoTheHour = calendar.component(.minute, from: date)

    if dayStartsAtNoon {
        // Shift the hour start by 12 hours, we're doing nights, not days
        hoursIntoTheDay = (hoursIntoTheDay + 12) % 24
    }

    let hourInSeconds = hoursIntoTheDay * 60 * 60
    let minuteInSeconds = minutesIntoTheHour * 60

    return secondsToY(hourInSeconds + minuteInSeconds, containerHeight: containerHeight)
}

/// Get the y placement for a specific numbers of seconds
func secondsToY(_ seconds: Int, containerHeight: CGFloat) -> CGFloat {
    let dayInSeconds: CGFloat = 86400
    let progress = CGFloat(seconds) / dayInSeconds
    return containerHeight * progress
}

func stageIndex(x: CGFloat, numberOfStages: Int, gridWidth: CGFloat) -> Int {
    let columnWidth = gridWidth / CGFloat(numberOfStages)

    return Int(x / columnWidth)
}

func yToTime(yPos: CGFloat, height: CGFloat, selectedDate: Date, dayStartsAtNoon: Bool) -> Date {
    return selectedDate
        .startOfDay(dayStartsAtNoon: dayStartsAtNoon)
        .addingTimeInterval(Double(yToSeconds(yPos: yPos, height: height)))
}

func yToSeconds(yPos: CGFloat, height: CGFloat) -> Int {
    let progress = yPos / height
    return Int(CGFloat(1.days) * progress)
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerCardsContainerView(store: .previewStore)
    }
}
