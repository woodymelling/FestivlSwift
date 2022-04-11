//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/29/22.
//

import Foundation
import SwiftUI
import Models
import ComposableArchitecture

struct ArtistSetCardView: View {
    var store: Store<ArtistSetCardState, ArtistSetCardAction>
    var viewHeight: CGFloat
    var selectedDate: Date

    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(viewStore.stage.color)
                        .brightness(colorScheme == .light ? -0.1 : 0.3)

                    HStack {
                        Rectangle()
                            .frame(width: 4)
                            .foregroundColor(viewStore.stage.color)
                            .brightness(colorScheme == .light ? -0.1 : 0.3)

                        GeometryReader { geo in
                            VStack(alignment: .leading) {

                                let hideArtistName = geo.size.height < 15
                                let hideSetTime = geo.size.height < 30
                                Text(viewStore.artistSet.artistName)
                                    .isHidden(hideArtistName, remove: hideArtistName)

                                Text(viewStore.artistSet.startTime.formatted(date: .abbreviated, time: .shortened))

                                Text(viewStore.artistSet.startTime...viewStore.artistSet.endTime)
                                    .font(.caption)
                                    .isHidden(hideSetTime, remove: hideSetTime)
                            }
                        }

                        Spacer()
                    }
                    .background(viewStore.stage.color)
                    .onTapGesture {
                        viewStore.send(.didTap)
                    }

                    VStack {
                        Spacer()
                        Circle()
                            .fill(.primary)
                            .frame(square: 8)
                            .opacity(0.5)
                            .onHover { inside in
                                if inside {
                                    NSCursor.resizeUpDown.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                            .offset(CGSize(width: 0, height: 4))
                            .gesture(
                                DragGesture(coordinateSpace: .named("ScheduleTimeline"))
                                    .onChanged { gesture in
                                        let newEndPosition = gesture.location.y
                                        let newEndTime = yToTime(
                                            yPos: newEndPosition,
                                            height: viewHeight,
                                            selectedDate: selectedDate,
                                            dayStartsAtNoon: viewStore.event.dayStartsAtNoon
                                        )

                                        DispatchQueue.main.async {
                                            viewStore.send(.didDrag(newEndTime: newEndTime))
                                        }

                                    }
                                    .onEnded { _ in
                                        DispatchQueue.main.async {
                                            viewStore.send(.didFinishDragging)
                                        }

                                    }
                            )

                    }
                }

            }
        }


    }
}
//
//struct ArtistSetCardView_Previews: PreviewProvider {
//    static var previews: some View {
////        ArtistSetCardView(
////            store: .init(initialState: .init(artistSet: .testData, stage: .test), reducer: <#T##Reducer<ArtistSetCardState, ArtistSetCardAction, Environment>#>, environment: <#T##Environment#>)
////        )
////            .previewLayout(.fixed(width: 200, height: 200))
////        .previewAllColorModes()
//    }
//}
