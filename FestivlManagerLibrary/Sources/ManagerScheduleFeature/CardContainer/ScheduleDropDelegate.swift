//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/31/22.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import Models

struct ScheduleDropDelegate: DropDelegate {
    var geometry: GeometryProxy
    var viewStore: ViewStore<ManagerScheduleState, ManagerScheduleAction>


    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [ArtistSet.typeIdentifier]).first else {
            return false
        }

        Task {

            guard let data = try? await itemProvider.loadItem(
                forTypeIdentifier: ArtistSet.typeIdentifier,
                options: nil
            ) as? Data, let typeIndicatedIdentifier = String(data: data, encoding: .utf8) else {
                print("Failed")
                return
            }

            let split = typeIndicatedIdentifier.split(separator: ":")

            let type = String(split[1])
            let id = String(split[2])

            let dropPoint = info.location

            let stageIndex = stageIndex(
                x: dropPoint.x,
                numberOfStages: viewStore.stages.count,
                gridWidth: geometry.size.width
            )
            

            guard let droppedStage = viewStore.stages[safe: stageIndex] else {
                print("Failed to find stage at index: \(stageIndex)")
                return
            }

            let droppedTime = yToTime(
                yPos: dropPoint.y,
                height: geometry.size.height,
                selectedDate: viewStore.selectedDate,
                dayStartsAtNoon: viewStore.event.dayStartsAtNoon
            )

            print("DroppedTime:", droppedTime.formatted(), "Dropped Stage: \(droppedStage.name)")

            switch type {
            case ArtistSet.typeString:
                guard let artistSet = viewStore.schedule.artistSets[id: id] else {
                    print("Failed to find artistSet with id:", id)
                    return
                }

                let newTime = droppedTime - (artistSet.setLength / 2)

                viewStore.send(.didMoveScheduleCard(artistSet.asScheduleItem(), newStage: droppedStage, newTime: newTime))

            case GroupSet.typeString:
                guard let groupSet = viewStore.schedule.groupSets[id: id] else {
                    print("Failed to find groupSet with id:", id)
                    return
                }

                let newTime = droppedTime - (groupSet.setLength / 2)

                viewStore.send(.didMoveScheduleCard(groupSet.asScheduleItem(), newStage: droppedStage, newTime: newTime))

            case Artist.typeString:

                guard let artist = viewStore.artists[id: id] else {
                    print("Failed to find artist with id:", id)
                    return
                }

                let time = droppedTime - (1.hours / 2)

                viewStore.send(.didDropArtist(artist, stage: droppedStage, time: time))
                

            default:
                print("Failed with no proper type")
            }
        }

        return true
    }


}

extension ArtistSet: DraggableItem {}
extension Artist: DraggableItem {}
extension GroupSet: DraggableItem {}

extension ScheduleItem: DraggableItem {
    var typeString: String {
        switch self.type {
        case .groupSet:
            return GroupSet.typeString
        case .artistSet:
            return ArtistSet.typeString
        }
    }
}

protocol DraggableItem: Identifiable where ID == String? {
    var typeString: String { get }
}


extension DraggableItem {

    var typeString: String {
        return Self.typeString
    }

    static var typeString: String {
        return String(describing: Self.self)
    }

    var itemProvider: NSItemProvider {
        print("Dragging Item")
        return NSItemProvider(object: "\(UUID().uuidString):\(self.typeString):\(self.id!)" as NSString)
    }

    static var typeIdentifier: String {
        "public.utf8-plain-text"
    }

}


