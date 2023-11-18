//
//  Event.swift
//
//
//  Created by Woody on 2/13/2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import Utilities
import Components
import ScheduleComponents
import FestivlDependencies

public struct EventView: View {
    let store: StoreOf<EventFeature>

    public init(store: StoreOf<EventFeature>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        var eventData: EventData?
        
        init(state: EventFeature.State) {
            self.eventData = state.eventData
        }
    }

    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            LoadingView(eventData: viewStore.eventData) { eventData in
                TabBarView(store: store)
                    .tint(eventData.event.mainEventColor)
                    .environment(\.event, eventData.event)
                    .environment(\.dayStartsAtNoon, eventData.event.dayStartsAtNoon)
                    .environment(\.stages, eventData.stages)
                
            }
            .task { await viewStore.send(.task).finish() }
        }
    }
}


struct LoadingView<Content: View>: View {
    var eventData: EventData?
    var content: (EventData) -> Content

    @State var rotationAngle: Double = 0
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    

    var body: some View {
        if let eventData, rotationAngle >= 720 {
            content(eventData)
        } else {
            FestivlCachedAsyncImage(url: eventData?.event.imageURL) {
                ProgressView()
            }
            .frame(square: 200)
            .rotationEffect(Angle(degrees: rotationAngle))
            .onReceive(timer) { _ in
                rotate()
            }
            .onAppear { rotate() }
        }
    }
    
    func rotate() {
        withAnimation(.spring()) {
            rotationAngle += 360
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(
            store: .init(
                initialState: .init(),
                reducer: EventFeature.init
            )
        )
    }
}
