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
                                .frame(height: scheduleHeight)

                                ZStack {

                                    ScheduleGridView()
                                        .frame(height: scheduleHeight)

                                    CardContainerView(style: style, store: store)
                                        .frame(height: scheduleHeight)

                                }
                            }

                            TimeIndicatorView(selectedDate: viewStore.selectedDate, dayStartsAtNoon: viewStore.event.dayStartsAtNoon)
                                .frame(height: scheduleHeight)
                        }
                    }
                    .frame(height: scheduleHeight)
                    .coordinateSpace(name: "ScheduleTimeline")
                }
                .onChange(of: viewStore.cardToDisplay, perform: { cardToDisplay in
                    withAnimation {
                        proxy.scrollTo(cardToDisplay?.id, anchor: .center)
                    }

                })
                .introspectScrollView { scrollView in
                    scrollViewHandler.scrollViewHandler.register(scrollView: scrollView)
                }
                .gesture(MagnificationGesture()
                    .onChanged(viewStore.send(.scrollViewDidZoom(<#T##UIScrollView#>))))



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
