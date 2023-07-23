//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/24/23.
//

import Foundation
import Utilities
import SwiftUI
import Components

public extension View {
    func toolbarDateSelector(
        selectedDate: Binding<CalendarDate>,
        addtionalContent: @escaping () -> some View = { EmptyView() }
    ) -> some View {
        self.modifier(ToolbarDateSelectorViewModifier(selectedDate: selectedDate, additionalContent: addtionalContent))
    }
}

struct ToolbarDateSelectorViewModifier<AdditionalContent: View>: ViewModifier {
    @Binding var selectedDate: CalendarDate
    @Environment(\.event) var event
    
    var additionalContent: () -> AdditionalContent
    
    
    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content
                .navigationTitle(Text(FestivlFormatting.weekdayFormat(for: selectedDate)))
                .toolbarTitleMenu {
                    ForEach(event.festivalDates, id: \.self) { date in
                        Button {
                            selectedDate = date
                        } label: {
                            Text(FestivlFormatting.weekdayFormat(for: date))
                        }
                    }
                    
                    Section {
                        additionalContent()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        } else {
            content
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Menu {
                            ForEach(event.festivalDates, id: \.self) { date in
                                Button {
                                    selectedDate = date
                                } label: {
                                    Text(FestivlFormatting.weekdayFormat(for: date))
                                }
                            }
                        } label: {
                            HStack {
                                Text(FestivlFormatting.weekdayFormat(for: selectedDate))
                                    .font(.title2)
                                Image(systemName: "chevron.down")
                                
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
        }
    }
}
