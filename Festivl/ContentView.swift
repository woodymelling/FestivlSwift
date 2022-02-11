//
//  ContentView.swift
//  Festivl
//
//  Created by Woody on 2/9/22.
//

import SwiftUI
import ArtistsFeature
import Models
import EventListFeature

struct ContentView: View {

    var body: some View {
        EventListView(
            store: .init(
                initialState: .init(),
                reducer: eventListReducer,
                environment: .init()
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
