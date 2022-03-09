//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/20/22.
//

import SwiftUI
import ComposableArchitecture
import Models

struct CardContainerView: View {

    var style: ScheduleStyle
    let store: Store<ScheduleState, ScheduleAction>

    func artistSets(for viewStore: ViewStore<ScheduleState, ScheduleAction>) -> [ArtistSet] {

        switch style {
        case .singleStage(let stage):
            return viewStore.artistSets.filter {
                stage.id == $0.stageID && $0.isOnDate(viewStore.selectedDate, dayStartsAtNoon: viewStore.event.dayStartsAtNoon)
            }

        case .allStages:
            return viewStore.artistSets.filter {
                $0.isOnDate(viewStore.selectedDate, dayStartsAtNoon: viewStore.event.dayStartsAtNoon)
            }
        }
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geo in
                let stageCount = style == .allStages ? viewStore.stages.count : 1

                ForEach(artistSets(for: viewStore)) { artistSet in

                    let size = artistSet.size(in: geo.size, stageCount: stageCount)
                    // Placement works by center of the view, move it to the top left
                    let offset = CGSize(width: size.width / 2, height: size.height / 2)

                    let xPosition = style == .allStages ?  artistSet.xPlacement(
                        stageCount: stageCount,
                        containerWidth: geo.size.width,
                        stages: viewStore.stages
                    ) : 0
                    
                    ArtistSetCardView(artistSet: artistSet, stages: viewStore.stages)
                        .frame(size: size)
                        .fixedSize()
                        .position(
                            x: xPosition,
                            y: artistSet.yPlacement(dayStartsAtNoon: viewStore.event.dayStartsAtNoon, containerHeight: geo.size.height)
                        )
                        .offset(offset)
                }
            }

        }


    }

}

struct CardContainerView_Previews: PreviewProvider {
    static var previews: some View {
        CardContainerView(style: .singleStage(.testValues[0]), store: .testStore)
    }
}
