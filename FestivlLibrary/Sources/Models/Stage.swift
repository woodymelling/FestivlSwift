//
//  File.swift
//  
//
//  Created by Woody on 2/13/22.
//

import Foundation
import FirebaseFirestoreSwift
import SwiftUI
import Utilities

public typealias StageID = String

public struct Stage: Codable, SettableIdentifiable, Hashable, Equatable {

    @DocumentID public var id: StageID?
    public let name: String
    public let symbol: String
    public let colorString: String
    public var iconImageURL: URL?
    public var sortIndex: Int

    public init(
        id: StageID? = nil,
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
                iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F0545133C-90A6-4A64-99F9-EA563A8E976E.png?alt=media&token=35509f1f-a977-47d2-bd76-2d3898d0e465"),
                sortIndex: 1
            ),

            Stage(
                id: "2",
                name: "The Village",
                symbol: "V",
                colorString: "#2FCAD3",
                iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F96A24076-86EB-4327-BC13-26B3A8B1B769.png?alt=media&token=cb596866-35e6-4e39-a018-004b7338d7e8"),
                sortIndex: 2
            ),

            Stage(
                id: "3",
                name: "The Pagoda",
                symbol: "P",
                colorString: "#AE1790",
                iconImageURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/festivl.appspot.com/o/userContent%2F980B90FE-4868-4E65-B0B8-045A54BEFBD2.png?alt=media&token=91037e7e-5702-424d-a4f5-f0c78c5c9fde"),
                sortIndex: 3
            )
        ]
    }
}
