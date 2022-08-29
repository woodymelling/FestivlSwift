//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/15/22.
//

import Foundation
import ComposableArchitecture

public struct SimpleSet: Codable {
    var startTime: Date
    var endTime: Date
    var title: String
    var stage: Stage
}

public protocol SimpleSetConvertible {
    var startTime: Date { get }
    var endTime: Date { get }
    var title: String { get }
    var stageID: StageID { get }
}

extension SimpleSetConvertible {
    public func asSimpleSet(stages: IdentifiedArrayOf<Stage>) -> SimpleSet? {
        guard let stage = stages[id: self.stageID] else { return nil }
        
        return SimpleSet(
            startTime: self.startTime,
            endTime: self.endTime,
            title: self.title,
            stage: stage
        )
    }
}

