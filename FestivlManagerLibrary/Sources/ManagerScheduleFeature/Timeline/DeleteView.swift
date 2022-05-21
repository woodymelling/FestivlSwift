//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/31/22.
//

import Foundation
import SwiftUI
import Utilities
import Models
import ComposableArchitecture

struct ScheduleDeleteView: View {
    let store: Store<ManagerScheduleState, ManagerScheduleAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Image(systemName: "trash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(square: 30)
                .onDrop(
                    of: [ArtistSet.typeIdentifier],
                    delegate: ScheduleDelegateDropDelegate(
                        viewStore: viewStore
                    )
                )
        }

    }
}

struct ScheduleDelegateDropDelegate: DropDelegate {
    let viewStore: ViewStore<ManagerScheduleState, ManagerScheduleAction>


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

            switch type {
            case ArtistSet.typeString:
                guard let artistSet = viewStore.schedule.artistSets[id: id] else {
                    print("Failed to find artistSet with id:", id)
                    return
                }

                viewStore.send(.deleteArtistSet(artistSet))

            case GroupSet.typeString:

                guard let groupSet = viewStore.schedule.groupSets[id: id] else {
                    print("Failed to find groupSet with id:", id)
                    return
                }

                viewStore.send(.deleteGroupSet(groupSet))

            default:
                print("Wrong drop type")
                return
            }
        }

        return true
    }
}


