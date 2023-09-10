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


public enum AuthenticationFlow: PickableValue {
    case signUp, signIn
    
    var label: LocalizedStringKey {
        switch self {
        case .signIn: "Sign In"
        case .signUp: "Sign Up"
        }
    }
}

public struct StartPageView: View {
    let store: StoreOf<StartPageDomain>
    
    public init(store: StoreOf<StartPageDomain>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        @BindingViewState var authFlow: AuthenticationFlow
        
        init(state: BindingViewStore<StartPageDomain.State>) {
            self._authFlow = state.$authFlow
        }
    }
    
    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ScrollView {
                VStack {
                    TitleView()
                        .padding(.top, 40)
                    
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
                    
                    SegmentedPickerWithPages(selectedOption: viewStore.$authFlow) {
                        switch $0 {
                        case .signIn:
                            SignInView(
                                store: self.store.scope(
                                    state: \.signInState,
                                    action: { .signIn($0) }
                                )
                            )
                        case .signUp:
                            SignUpView(
                                store: self.store.scope(
                                    state: \.signUpState,
                                    action: { .signUp($0) }
                                )
                            )
                        }
                    }
                    .padding(.top)
                    .frame(height: 300) // Scrollview is making this resize improperly
                    
                    Spacer()
                }
            }
            .frame(width: 300)
        }

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
        StartPageView(
            store: .init(
                initialState: .init(),
                reducer: StartPageDomain.init
            )
        )
    }
}

protocol PickableValue: CaseIterable, Hashable {
    var label: LocalizedStringKey { get }
}

extension Picker
where SelectionValue: PickableValue,
      Content == ForEach<Array<SelectionValue>, SelectionValue, Label>,
      Label == Text
{
    init(selection: Binding<SelectionValue>, label: () -> Label) {
        self.init(
            selection: selection,
            content: { 
                ForEach(Array(SelectionValue.allCases), id: \.self) {
                    Text($0.label)
                }
            },
            label: label
        )
    }
    
    init(_ titleKey: LocalizedStringKey, selection: Binding<SelectionValue>) {
        self.init(
            titleKey,
            selection: selection,
            content: { 
                ForEach(Array(SelectionValue.allCases), id: \.self) {
                    Text($0.label)
                }
            }
        )
    }
}

struct SegmentedPickerWithPages<SelectionValue: PickableValue, Content: View>: View {
    
    @Binding var selectedOption: SelectionValue
    @ViewBuilder var content: (SelectionValue) -> Content
    
    init(
        selectedOption: Binding<SelectionValue>,
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self._selectedOption = selectedOption
        self.content = content
    }
    
    var body: some View {
        VStack {
            Picker("Sign In / Out", selection: $selectedOption)
                .pickerStyle(.segmented)
            
            TabView(selection: $selectedOption) {
                ForEach(Array(SelectionValue.allCases), id: \.self) {
                    content($0)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .animation(.default, value: selectedOption)
    }
}


fileprivate struct SegmentedPickerWithPages_Preview: View {
    
    enum Option: PickableValue {
        case first, second, third
        
        var label: LocalizedStringKey {
            switch self {
            case .first: "First"
            case .second: "Second"
            case .third: "Third"
            }
        }
    }
    
    @State var option: Option = .first
    
    var body: some View {
        SegmentedPickerWithPages(selectedOption: $option) {
            switch $0 {
            case .first: Label("First", systemImage: "star")
            case .second: Label("Second", systemImage: "circle")
            case .third: Label("Third", systemImage: "square")
            }
        }
    }
}

#Preview {
    SegmentedPickerWithPages_Preview()
        .padding()
        .frame(height: 400)
}
