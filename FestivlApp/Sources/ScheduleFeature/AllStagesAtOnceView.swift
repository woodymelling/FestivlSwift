//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/21/22.
//

import SwiftUI
import ComposableArchitecture

struct AllStagesAtOnceView: View {
    let store: Store<ScheduleState, ScheduleAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScheduleScrollView(store: store, style: .allStages, scrollViewHandler: .init())
        }
    }
}

struct AllStagesAtOnceView_Previews: PreviewProvider {
    static var previews: some View {
        AllStagesAtOnceView(store: .testStore)
    }
}
