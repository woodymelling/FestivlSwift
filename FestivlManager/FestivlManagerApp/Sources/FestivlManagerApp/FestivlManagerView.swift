//
//  FestivlManagerView.swift
//  
//
//  Created by Woodrow Melling on 8/1/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import OnboardingFeature

public struct FestivlManagerView: View {
    
    let store: StoreOf<FestivlManagerDomain>
    
    public init(store: StoreOf<FestivlManagerDomain>) {
        self.store = store
    }
    
    public var body: some View {
        HomeView(
            store: store.scope(state: \.home, action: { .home($0) })
        )
        .task { store.send(.task) }
        .sheet(
            store: store.scope(state: \.$onboarding, action: { .onboarding($0) }),
            content: OnboardingView.init
        )
    }
}

import Combine

#Preview {
    FestivlManagerView(store: Store(initialState: FestivlManagerDomain.State()) {
        FestivlManagerDomain()
            .transformDependency(\.sessionClient.publisher) {
                $0 = { Just(nil).eraseToAnyPublisher() }
            }
    })
}
