//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import FirebaseFirestoreSwift
import Utilities
import Foundation
import ComposableArchitecture
import SwiftUI

public struct ArtistSet: Identifiable, Codable, Equatable, StageScheduleCardRepresentable {

    @DocumentID public var id: String?
    public var artistID: Artist.ID
    public var artistName: String
    public var stageID: StageID
    public var startTime: Date
    public var endTime: Date

    public init(
        id: String?,
        artistID: Artist.ID,
        artistName: String,
        stageID: StageID,
        startTime: Date,
        endTime: Date
    ) {
        self.id = id
        self.artistID = artistID
        self.artistName = artistName
        self.stageID = stageID
        self.startTime = startTime
        self.endTime = endTime
    }
}

extension ArtistSet {
    public var setLength: TimeInterval {
        endTime.timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate
    }
}

extension ArtistSet {
    public static var testData: ArtistSet {
        return ArtistSet(
            id: nil,
            artistID: "",
            artistName: "Rythmbox",
            stageID: "0",
            startTime: Date(),
            endTime: Date() + 1.hours
        )
    }

    public static func testValues(
        artists: [Artist] = Artist.testValues,
        stages: [Stage] = Stage.testValues,
        count: Int = 10,
        setLengthMinutes: Int = 60,
        startTime: Date = Calendar.current.date(from: DateComponents(hour: 13))!
    ) ->  [ArtistSet] {
        (0...count).map {
            let artist = artists[wrapped: $0]

            let startTime = Calendar.current.date(byAdding: .minute, value: setLengthMinutes * $0, to: startTime)!
            let endTime = Calendar.current.date(byAdding: .minute, value: setLengthMinutes, to: startTime)!

            return ArtistSet(
                id: String($0),
                artistID: artist.id!,
                artistName: artist.name,
                stageID: stages[wrapped: $0].id!,
                startTime: startTime,
                endTime: endTime
            )
        }
    }
}

public protocol ScheduleCardRepresentable {
    var startTime: Date { get }
    var endTime: Date { get }
}

public protocol StageScheduleCardRepresentable: ScheduleCardRepresentable {
    var stageID: StageID { get }
}

public extension ScheduleCardRepresentable {


    /// Get the frame size for an artistSet in a specfic container
    func size(in containerSize: CGSize, stageCount: Int) -> CGSize {
        let setLengthInSeconds = endTime.timeIntervalSince(startTime)
        let height = secondsToY(Int(setLengthInSeconds), containerHeight: containerSize.height)
        let width = containerSize.width / CGFloat(stageCount)
        return CGSize(width: width, height: height)
    }

    /// Get the y placement for a set in a container of a specific height
    func yPlacement(dayStartsAtNoon: Bool, containerHeight: CGFloat) -> CGFloat {
        return startTime.toY(containerHeight: containerHeight, dayStartsAtNoon: dayStartsAtNoon)
    }



    func isOnDate(_ date: Date, dayStartsAtNoon: Bool) -> Bool {
        let startTime = dayStartsAtNoon ? Calendar.current.date(byAdding: .hour, value: 12, to: startTime)! : startTime
        return Calendar.current.isDate(startTime, inSameDayAs: date)
    }
}

public extension StageScheduleCardRepresentable {
    func xPlacement(stageCount: Int, containerWidth: CGFloat, stages: IdentifiedArrayOf<Stage>) -> CGFloat {
        return containerWidth / CGFloat(stageCount) * CGFloat(stages.index(id: stageID)!)
    }
}


public extension Date {
    func toY(containerHeight: CGFloat, dayStartsAtNoon: Bool) -> CGFloat {

        let calendar = Calendar.autoupdatingCurrent

        var hoursIntoTheDay = calendar.component(.hour, from: self)
        let minutesIntoTheHour = calendar.component(.minute, from: self)

        if dayStartsAtNoon {
            // Shift the hour start by 12 hours, we're doing nights, not days
            hoursIntoTheDay = (hoursIntoTheDay + 12) % 24
        }

        let hourInSeconds = hoursIntoTheDay * 60 * 60
        let minuteInSeconds = minutesIntoTheHour * 60

        return secondsToY(hourInSeconds + minuteInSeconds, containerHeight: containerHeight)
    }
}


/// Get the y placement for a specific numbers of seconds
public func secondsToY(_ seconds: Int, containerHeight: CGFloat) -> CGFloat {
    let dayInSeconds: CGFloat = 86400
    let progress = CGFloat(seconds) / dayInSeconds
    return containerHeight * progress
}
