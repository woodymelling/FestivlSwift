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

public struct EventView: View {
    let store: StoreOf<EventFeature>

    public init(store: StoreOf<EventFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: Blank.init) { viewStore in
            TabBarView(store: store)
                .task { await viewStore.send(.task).finish() }
        }
    }
}


struct LoadingView: View {
    var event: Event

    @State var rotationAngle: Double = 0

    @State var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        CachedAsyncImage(url: event.imageURL, renderingMode: .template, placeholder: {
            ProgressView()

        })
        .frame(square: 300)
        .rotationEffect(Angle(degrees: rotationAngle))
        .onReceive(timer) { _ in
            withAnimation(.spring()) {
                rotationAngle += 360
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                rotationAngle += 360
            }

        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(
            store: .init(
                initialState: .init(),
                reducer: EventFeature()
            )
        )
    }
}
