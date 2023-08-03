//
//  FestivlManagerView.swift
//  
//
//  Created by Woodrow Melling on 8/1/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

public struct FestivlManagerView: View {
    
    let store: StoreOf<FestivlManagerDomain>
    
    public init(store: StoreOf<FestivlManagerDomain>) {
        self.store = store
    }
    
    public var body: some View {
        IfLetStore(
            store.scope(state: \.$loggedInState, action: { .loggedIn($0) } ),
            then: LoggedInView.init
        ) {
            HomePageView(store: store.scope(state: \.homePageState, action: { .homePage($0) } ))
        }
        .task { store.send(.task) }
    }
}
