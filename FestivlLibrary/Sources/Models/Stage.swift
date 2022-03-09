//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import Foundation
import FirebaseFirestoreSwift
import SwiftUI

public typealias StageID = String

public struct Stage: Codable, Identifiable, Hashable, Equatable {

    @DocumentID public var id: StageID?
    public let name: String
    public let symbol: String
    public let colorString: String
    public let iconImageURL: URL?
    public let sortIndex: Int

    public init(
        id: StageID?,
        name: String,
        symbol: String,
        colorString: String,
        iconImageURL: URL?,
        sortIndex: Int
    ) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.colorString = colorString
        self.iconImageURL = iconImageURL
        self.sortIndex = sortIndex
    }
}

extension Stage {
    public var color: Color {
        Color(hex: colorString)
    }
}

extension Stage {
    public static var testData: Stage {
        return Stage(
            id: "0",
            name: "The Living Room",
            symbol: "L",
            colorString: "#FF9F0A",
            iconImageURL: nil,
            sortIndex: 0
        )
    }

    public static var testValues: [Stage] {
        [
            .testData,

            Stage(
                id: "1",
                name: "The Fractal Forest",
                symbol: "F",
                colorString: "#3D8E53",
                iconImageURL: nil,
                sortIndex: 1
            ),

            Stage(
                id: "2",
                name: "The Village",
                symbol: "V",
                colorString: "#2FCAD3",
                iconImageURL: nil,
                sortIndex: 2
            )
        ]
    }
}
