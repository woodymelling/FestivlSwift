//
//  SlantedListTests.swift
//  
//
//  Created by Woody on 3/7/22.
//

import XCTest
@testable import ExploreFeature

class SlantedListTests: XCTestCase {

    func testUnrotatedSquare() throws {


        let spacing = calculateSpacing(
            height: 10,
            width: 10,
            rotationAngle: .degrees(0))

        XCTAssertEqual(spacing, 0)
    }

    func test90DegreeRotatedSquare() throws {
        let spacing = calculateSpacing(
            height: 10,
            width: 10,
            rotationAngle: .degrees(90)
        )

        XCTAssertEqual(spacing, 0)
    }

    func test45DegreeRotatedSquare() throws {
        let sideLength: CGFloat = 10
        let spacing = calculateSpacing(height: sideLength, width: sideLength, rotationAngle: .degrees(45))

        let expected = (sqrt(2) * sideLength) / 2
    }
}
