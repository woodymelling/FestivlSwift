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
    let store: Store<ScheduleState, ScheduleAction>
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
                                    currentTime: viewStore.currentTime, shouldHideTime: viewStore.shouldShowTimeIndicator
                                )

                                ZStack {

                                    ScheduleGridView()
                                    CardContainerView(style: style, store: store)

                                }
                            }

                            if viewStore.shouldShowTimeIndicator {
                                TimeIndicatorView(currentTime: viewStore.currentTime)
                                    .position(x: geo.size.width / 2, y: viewStore.currentTime.toY(containerHeight: geo.size.height, dayStartsAtNoon: viewStore.event.dayStartsAtNoon))
                            }

                        }


                    }
                    .frame(height: scheduleHeight)
                    .coordinateSpace(name: "ScheduleTimeline")


                }
                .onChange(of: viewStore.cardToDisplay, perform: { cardToDisplay in
                    withAnimation {
                        proxy.scrollTo(cardToDisplay?.id, anchor: .top)
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

struct ScheduleScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleScrollView(store: .testStore, style: .allStages, scrollViewHandler: .init())
    }
}
