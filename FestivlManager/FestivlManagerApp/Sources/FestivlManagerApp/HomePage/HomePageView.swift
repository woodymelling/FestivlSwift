//
//  File.swift
//
//
//  Created by Woodrow Melling on 7/25/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import SharedResources
import Utilities

public struct HomePageView: View {
    let store: StoreOf<HomePageDomain>
    
    public init(store: StoreOf<HomePageDomain>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            TitleView()
            
            VStack {
                InfoView(
                    title: "Your Festivals App",
                    "Amplify the festival experience, putting the stage lineup, information, maps, and real-time updates at attendees' fingertips."
                ) {
                    FestivlAssets.Icons.handWithSmartphone
                        .resizable()
                        .foregroundStyle(Color.systemBlue)
                }
                
                InfoView(
                    title: "Manage Schedule",
                    "Create the schedule for your event, and update info in the app live during showtime."
                ) {
                    Image(systemName: "calendar")
                        .resizable()
                        .foregroundStyle(Color.systemPurple)
                    
                }
                
                InfoView(
                    title: "Notifications",
                    "Real-time notifications for schedule changes and important updates, keeping attendees informed during the festival."
                ) {
                    Image(systemName: "bell.badge")
                        .resizable()
                        .foregroundStyle(Color.systemRed)
                }
            }
            
            Spacer()
            Spacer()
            
            VStack {
                Button { store.send(.didTapSignInButton) } label: {
                    Text("Log In")
                        .frame(width: 200)
                }
                .buttonStyle(.borderless)
                
                Button { store.send(.didTapSignUpButton) } label: {
                    Text("Sign Up")
                        .frame(width: 200)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 300)
        .sheet(
            store: self.store.scope(state: \.$destination, action: { .destination($0) }),
            state: /HomePageDomain.Destination.State.signIn,
            action: HomePageDomain.Destination.Action.signIn,
            content: { store in
                NavigationStack {
                    SignInView(store: store)
                }
            }
        )
        .navigationDestination(
            store: self.store.scope(state: \.$destination, action: { .destination($0) }),
            state: /HomePageDomain.Destination.State.signUp,
            action: HomePageDomain.Destination.Action.signUp,
            content: { SignUpView(store: $0) }
        )
    }
    
    struct TitleView: View {
        var body: some View {
            VStack(spacing: 0) {
                Text("Welcome to                  ")
                    .lineLimit(1)
                
                Text("Festivl Manager  ")
                    .foregroundStyle(Color.accentColor)
                    .lineLimit(1)
            }
            .accessibilityRepresentation { Text("Welcome to Festivl") }
            .lineLimit(1)
            .fontWeight(.heavy)
            .font(.system(size: 100))
            .minimumScaleFactor(0.1)
        }
    }
    
    struct InfoView<ImageContent: View>: View {
        var title: LocalizedStringKey
        var content: LocalizedStringKey
        var image: () -> ImageContent
        
        init(title: LocalizedStringKey, _ content: LocalizedStringKey, image: @escaping () -> ImageContent) {
            self.title = title
            self.content = content
            self.image = image
        }
        
        var body: some View {
            HStack(spacing: 20) {
                image()
                    .aspectRatio(contentMode: .fit)
                    .frame(square: 60)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    
                    Text(content)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview("Home Page") {
    NavigationStack {
        HomePageView(
            store: .init(
                initialState: .init(),
                reducer: HomePageDomain.init
            )
        )
    }
}

