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
    let headerHeight: CGFloat

    @ObservedObject var scrollViewHandler: SingleStageAtOnceView.ViewModel

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                Spacer()
                    .frame(height: headerHeight)
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
            .onAppear {
                print("HEADER HEIGHT", headerHeight)
            }
        }

    }
}

struct ScheduleScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleScrollView(store: .testStore, style: .allStages, headerHeight: 0, scrollViewHandler: .init())
    }
}
