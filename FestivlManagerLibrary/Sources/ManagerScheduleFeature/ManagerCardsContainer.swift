//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 3/29/22.
//

import SwiftUI
import ComposableArchitecture
import Models

struct ManagerCardsContainerView: View {
    let store: Store<ManagerScheduleState, ManagerScheduleAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geo in
                ForEach(viewStore.artistSetsForDate) { artistSet in

                    let size = sizeForSet(
                        artistSet,
                        containerSize: geo.size,
                        stageCount: viewStore.stages.count
                    )
                    // Placement works by center of the view, move it to the top left
                    let offset = CGSize(width: size.width / 2, height: size.height / 2)

                    ArtistSetCardView(
                        artistSet: artistSet,
                        stage: viewStore.stages[id: artistSet.stageID]!
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
                    .onTapGesture {
                        viewStore.send(.didTapArtistSet(artistSet))
                    }
                }
            }
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

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerCardsContainerView(store: .previewStore)
    }
}
