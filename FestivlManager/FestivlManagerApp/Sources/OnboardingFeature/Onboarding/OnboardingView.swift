//
//  OnboardingView.swift
//  
//
//  Created by Woodrow Melling on 8/13/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

public struct OnboardingView: View {
    let store: StoreOf<OnboardingDomain>

    public init(store: StoreOf<OnboardingDomain>) {
        self.store = store
    }

    public var body: some View {
        NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) }) ) {
            StartPageView(
                store: store.scope(
                    state: \.startPage,
                    action: OnboardingDomain.Action.startPage
                )
            )
        } destination: { state in
            switch state {
            case .createOrganization:
                CaseLet(
                    /OnboardingDomain.Path.State.createOrganization,
                     action: OnboardingDomain.Path.Action.createOrganization,
                     then: CreateOrganizationView.init
                )
            case .createEvent:
                CaseLet(
                    /OnboardingDomain.Path.State.createEvent,
                    action: OnboardingDomain.Path.Action.createEvent,
                    then: CreateEventView.init
                )
            }
        }
    }
}


#Preview {
    Text("Blah")
        .sheet(isPresented: .constant(true), content: {
            OnboardingView(store: Store(initialState: OnboardingDomain.State()) {
                OnboardingDomain()
                    ._printChanges()
            })
        })

}
