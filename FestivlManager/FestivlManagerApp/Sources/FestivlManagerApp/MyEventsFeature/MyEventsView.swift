//
//  MyEventsView.swift
//  
//
//  Created by Woodrow Melling on 8/2/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct LoggedInView: View {
    let store: StoreOf<LoggedInDomain>
    
    var body: some View {
        Button("Logout") {
            store.send(.didTapLogout)
        }
    }
}
