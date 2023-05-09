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

    @ScaledMetric var scheduleHeight: CGFloat = 1500
    
    var color: Color {
        switch style {
        case .singleStage(let stage):
            return stage.color
        case .allStages:
            return .label
        }
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            ScrollViewReader { proxy in
                ScrollView {
                    GeometryReader { geo in
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
                    .frame(height: scheduleHeight)
                }
                .onChange(of: viewStore.cardToDisplay, perform: { cardToDisplay in
                    withAnimation {
                        proxy.scrollTo(cardToDisplay?.id)
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
