//
//  File.swift
//
//
//  Created by Woodrow Melling on 8/26/23.
//

import Foundation
import XCTest
@testable import OnboardingFeature
import ComposableArchitecture
import SwiftUI
import PhotosUI

@MainActor
class CreateEventTests: XCTestCase {
    func testHappyPath() async {
        let todaysDate = Date.from(year: 2023, month: 8, day: 26)!
        let startDate = Date.from(year: 2023, month: 10, day: 12)!
        let endDate = Date.from(year: 2023, month: 12, day: 14)!

        let state = withDependencies {
            $0.date = .constant(todaysDate)
            $0.timeZone = .gmt
        } operation: {
            CreateEventDomain.State()
        }

        XCTAssertEqual(
            state,
            CreateEventDomain.State(
                startDate: todaysDate,
                endDate: todaysDate.addingTimeInterval(1.days),
                timeZone: .gmt,
                dayStartsAtNoon: false
            )
        )

        let pickerItem = PhotosPickerItem(itemIdentifier: "photo")
        let image = Image(systemName: "star")

        let store = TestStore(initialState: state) {
            CreateEventDomain()
        } withDependencies: {
            $0.photosPickerClient.loadTransferable = { _ in image }
        }

        await store.send(.binding(.set(\.$startDate, startDate))) {
            $0.startDate = startDate
            $0.endDate = startDate.addingTimeInterval(1.days)
        }

        await store.send(.binding(.set(\.$endDate, endDate))) {
            $0.endDate = endDate
        }

        await store.send(.binding(.set(\.$dayStartsAtNoon, true))) {
            $0.dayStartsAtNoon = true
        }

        await store.send(.binding(.set(\.$eventImage, .init(pickerItem: pickerItem)))) {
            $0.eventImage.pickerItem = pickerItem
        }

        await store.receive(.photosPicker(.didLoadImage(image))) {
            $0.eventImage.image = image
        }

        await store.send(.didTapCreateEvent)

        await store.receive(.delegate(.didFinishCreatingEvent))
    }
}
