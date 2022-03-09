//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/21/22.
//

import SwiftUI
import ComposableArchitecture
import Utilities

struct ScheduleScrollView: View {
    let store: Store<ScheduleState, ScheduleAction>
    let style: ScheduleStyle
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
        ScheduleScrollView(store: .testStore, style: .allStages)
    }
}
