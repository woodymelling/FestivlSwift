//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 8/8/23.
//

import SwiftUI
import Utilities

public struct TimeZonePicker: View {
    
    var title: LocalizedStringKey = "Time Zone"
    @Binding var selectedTimeZone: TimeZone
    
    
    public init(_ title: LocalizedStringKey = "Time Zone", selectedTimeZone: Binding<TimeZone>) {
        self.title = title
        self._selectedTimeZone = selectedTimeZone
    }
    
    enum Destination {
        case timeZoneList
    }
    
    @State private var isShowingTimeZoneList: Bool = false
    @Environment(\.locale) private var locale
    
    
    public var body: some View {
        Button(action: {
            self.isShowingTimeZoneList = true
        }, label: {
            HStack() {
                Text(title)
                
                Spacer()
                
                Text(selectedTimeZone.localizedName(for: .generic, locale: locale) ?? selectedTimeZone.identifier)
                    .foregroundStyle(Color.secondary)
            }
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        .navigationLinkButtonStyle()
        .navigationDestination(isPresented: $isShowingTimeZoneList) {
            TimeZoneList(selectedTimeZone: $selectedTimeZone)
        }
    }
}


struct TimeZoneList: View {
    var timeZones: [TimeZone] = TimeZone
        .knownTimeZoneIdentifiers
        .compactMap(TimeZone.init(identifier:))
        .sorted(by: \.identifier)

//    var timeZones: [TimeZone] = []


    @Environment(\.locale) var locale
    @Environment(\.timeZone) var currentTimeZone
    @Environment(\.dismiss) var dismiss

    @Binding var selectedTimeZone: TimeZone
    @State var searchText: String = ""

    var filteredTimeZones: [TimeZone] {
        timeZones.filterForSearchTerm(
            searchText,
            terms: {
                let searchTerms: [String?] = [
                    $0.identifier,
                    $0.displayName,
                    $0.localizedName(for: .standard, locale: locale),
                    $0.localizedName(for: .generic, locale: locale)
                ]

                return searchTerms.compactMap { $0 }
            }
        )
    }

    var body: some View {
        List {
            ForEach(filteredTimeZones, id: \.self) { timeZone in
                 Button(timeZone.displayName) {
                     self.selectedTimeZone = timeZone
                     self.dismiss()
                 }
                 .buttonStyle(.plain)
             }
             .listStyle(.plain)
        }
        .task {
            withAnimation {
                self.searchText = self.selectedTimeZone.identifier
            }
        }
        .navigationTitle("Time Zone")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .autocorrectionDisabled()
    }
}


fileprivate struct TimeZonePicker_Preview: View {
    @State var timeZone: TimeZone = TimeZone.autoupdatingCurrent
    var body: some View {
        NavigationStack {
            List {
                Picker("Time Zone", selection: .constant("Denver")) {
                    Button("Denver") {}
                        .buttonStyle(.plain)
                }
                .pickerStyle(.navigationLink)

                TimeZonePicker(selectedTimeZone: $timeZone)
            }
        }
    }
}

#Preview {
    TimeZonePicker_Preview()
}


