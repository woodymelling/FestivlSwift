//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/21/22.
//

import SwiftUI
import ComposableArchitecture
import Models
import Components
import Utilities

struct AllStagesAtOnceView: View {
    let store: StoreOf<ScheduleFeature>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScheduleScrollView(store: store, style: .allStages, scrollViewHandler: .init())
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        StagesIndicatorView(stages: viewStore.stages)
                    }
                })
        }
    }
}

struct StagesIndicatorView: View {
    var stages: IdentifiedArrayOf<Stage>
    var body: some View {
        HStack {
            ForEach(stages) { stage in
                CachedAsyncImage(url: stage.iconImageURL, renderingMode: .template, placeholder: {
                    ProgressView()
                })
                .foregroundColor(stage.color)
                .frame(square: 50)

            }
        }
    }
}

//struct AllStagesAtOnceView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllStagesAtOnceView(store: .testStore)
//    }
//}
