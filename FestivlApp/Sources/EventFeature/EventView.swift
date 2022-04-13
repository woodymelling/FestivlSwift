//
//  Event.swift
//
//
//  Created by Woody on 2/13/2022.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct EventView: View {
    let store: Store<EventState, EventAction>

    public init(store: Store<EventState, EventAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in

            Group {
                if viewStore.eventLoaded {
                    TabBarView(store: store.scope(state: \.tabBarState, action: EventAction.tabBarAction))
                } else {
                    LoadingView(event: viewStore.event)
                }

            }
            .onAppear { viewStore.send(.subscribeToDataPublishers) }
        }
    }
}


struct LoadingView: View {
    var event: Event

    @State var rotationAngle: Double = 0

    @State var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        AsyncImage(url: event.imageURL) { (phase: AsyncImagePhase) in
            switch phase {
            case .empty, .failure:
                ProgressView()
            case .success(let image):
                image
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
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



            @unknown default:
                ProgressView()
            }
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            EventView(
                store: .init(
                    initialState: .init(event: .testData),
                    reducer: eventReducer,
                    environment: .init()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
