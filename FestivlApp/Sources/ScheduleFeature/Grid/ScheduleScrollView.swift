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

struct ScheduleScrollView: View {
    let store: Store<ScheduleState, ScheduleAction>
    let style: ScheduleStyle
    @ObservedObject var scrollViewHandler: SingleStageAtOnceView.ViewModel

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {

                HStack {
                    ScheduleHourLabelsView(dayStartsAtNoon: true)

                    ZStack {
                        ScheduleGridView()
                        CardContainerView(style: style, store: store)
                    }
                }
                .frame(height: 1000 * viewStore.zoomAmount)
            }
            .introspectScrollView { scrollView in
                scrollViewHandler.scrollViewHandler.register(scrollView: scrollView)
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        viewStore.send(.zoomed(value.magnitude))
                    }
            )
        }

    }
}

struct ScheduleScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleScrollView(store: .testStore, style: .allStages, scrollViewHandler: .init())
    }
}
