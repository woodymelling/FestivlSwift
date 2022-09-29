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

public struct EventView: View {
    let store: StoreOf<EventFeature>

    public init(store: StoreOf<EventFeature>) {
        self.store = store
    }

    @AppStorage("favoriteArtists") var favoriteArtists: Data = .init()


    public var body: some View {
        WithViewStore(store) { viewStore in

            Group {
                if viewStore.eventLoaded {
                    TabBarView(store: store.scope(state: \.tabBarState, action: EventFeature.Action.tabBarAction))
                } else {
                    LoadingView(event: viewStore.event)
                }

            }
            .onAppear { viewStore.send(.onAppear) }
            .onChange(of: viewStore.favoriteArtists, perform: { _ in
                print("CHANGED FAVORITE ARTISTS")
            })
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
        ForEach(ColorScheme.allCases.reversed(), id: \.self) {
            EventView(
                store: .init(
                    initialState: .init(event: .testData, isTestMode: true, isEventSpecificApplication: false),
                    reducer: EventFeature()
                )
            )
            .preferredColorScheme($0)
        }
    }
}
