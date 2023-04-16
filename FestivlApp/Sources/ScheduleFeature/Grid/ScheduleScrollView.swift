//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/21/22.
//

import SwiftUI
import ComposableArchitecture
import Utilities
import Introspect
import SimultaneouslyScrollView
import Combine

struct ScheduleScrollView: View {
    let store: StoreOf<ScheduleFeature>
    let style: ScheduleStyle

    @ObservedObject var scrollViewHandler: SingleStageAtOnceView.ViewModel

    @ScaledMetric var scheduleHeight: CGFloat = 1000

    var body: some View {
        WithViewStore(store) { viewStore in
            
            ScrollViewReader { proxy in
                ScrollView {
                    GeometryReader { geo in
                        ZStack {


                            HStack {
                                ScheduleHourLabelsView(
                                    dayStartsAtNoon: viewStore.event.dayStartsAtNoon,
                                    shouldHideTime: viewStore.shouldShowTimeIndicator
                                )
                                .frame(height: scheduleHeight * viewStore.zoomAmount)

                                ZStack {

                                    ScheduleGridView()
                                        .frame(height: scheduleHeight * viewStore.zoomAmount)

                                    CardContainerView(style: style, store: store)
                                        .frame(height: scheduleHeight * viewStore.zoomAmount)

                                }
                            }

                            TimeIndicatorView(selectedDate: viewStore.selectedDate, dayStartsAtNoon: viewStore.event.dayStartsAtNoon)
                                .frame(height: scheduleHeight * viewStore.zoomAmount)
                        }
                    }
                    .coordinateSpace(name: "ScheduleTimeline")
                    .frame(height: scheduleHeight * viewStore.zoomAmount)
                    .highPriorityGesture(
                        MagnificationGesture(minimumScaleDelta: 0)
                            .onChanged {
                                viewStore.send(.zoomed($0.magnitude))

                            }
                            .onEnded { _ in
                                viewStore.send(.finishedZooming)
                            }
                    )
                }
                .onChange(of: viewStore.cardToDisplay, perform: { cardToDisplay in
                    withAnimation {
                        proxy.scrollTo(cardToDisplay?.id, anchor: .center)
                    }

                })
                .introspectScrollView { scrollView in
                    scrollViewHandler.scrollViewHandler.register(scrollView: scrollView)
                }

            }
        }

    }
}

var scrollViewCancellables = Set<AnyCancellable>()
//
//struct ScheduleScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScheduleScrollView(store: .testStore, style: .allStages, scrollViewHandler: .init())
//    }
//}
