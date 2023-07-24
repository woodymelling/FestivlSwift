//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 5/21/22.
//

import SwiftUI
import Models
import ComposableArchitecture
import Utilities


public struct ContactInfoFeature: Reducer {
    @Dependency(\.openURL) var openURL
    
    public struct State: Equatable {
        var contactNumbers: IdentifiedArrayOf<ContactNumber>
    }
    
    public enum Action {
        case didTapContactNumber(ContactNumber)
    }
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .didTapContactNumber(contactNumber):
            guard let url = URL(string: "tel:\(contactNumber.phoneNumber)") else { return .none }
            
            return .run { _ in
                await openURL(url)
            }
        }
    }
}

struct ContactInfoView: View {
    let store: StoreOf<ContactInfoFeature>

    var body: some View {
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.contactNumbers) { contactNumber in
                    Button {
                        viewStore.send(.didTapContactNumber(contactNumber))
                    } label: {
                        
                        HStack {
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contactNumber.title)
                                    .font(.headline)
                                Text(contactNumber.phoneNumber.asPhoneNumber)
                                    .textSelection(.enabled)
                                
                                Text(contactNumber.description)
                                    .font(.caption)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "phone.fill")
                                .resizable()
                                .frame(square: 20)
                                .foregroundColor(.accentColor)
                            
                        }
                        .padding()
                        
                    }
                    .buttonStyle(.plain)
                    
                }
            }
            .navigationTitle("Contact Info")
        }
    }
}

extension String {
    var asPhoneNumber: String {
        self.applyPatternOnNumbers(pattern: "(###) ###-####", replacementCharacter: "#")
    }

    func applyPatternOnNumbers(pattern: String, replacementCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}

struct ContactInfoView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationStack {
            ContactInfoView(
                store: .init(
                    initialState: ContactInfoFeature.State(
                        contactNumbers: .init(
                            uniqueElements: [
                                .init(
                                    title: "Emergency Services",
                                    phoneNumber: "5555551234",
                                    description: "This will connect you directly with our switchboard, and alert the appropriate services."
                                ),
                                .init(
                                    title: "General Information Line",
                                    phoneNumber: "5555554321",
                                    description: "For general information, questions or concerns, or to report any sanitation issues within the WW grounds, please contact this number."
                                )
                        ])
                    ),
                    reducer: ContactInfoFeature.init
                )
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
