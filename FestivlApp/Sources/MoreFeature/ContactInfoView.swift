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



struct ContactInfoView: View {
    var contactNumbers: IdentifiedArrayOf<ContactNumber>

    private func callNumber(phoneNumber: String) {
        guard let url = URL(string: "tel:\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    var body: some View {
        List {
            ForEach(contactNumbers) { contactNumber in
                Button {
                    callNumber(phoneNumber: contactNumber.phoneNumber)
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
        NavigationView {
            ContactInfoView(contactNumbers: .init(uniqueElements: [
                .init(title: "Emergency Services", phoneNumber: "5555551234", description: "This will connect you directly with our switchboard, and alert the appropriate services."),
                .init(title: "General Information Line", phoneNumber: "5555554321", description: "For general information, questions or concerns, or to report any sanitation issues within the WW grounds, please contact this number.")
            ]))
            .navigationBarTitleDisplayMode(.inline)
        }

        .previewAllColorModes()
    }
}
