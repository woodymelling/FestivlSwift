////
////  File.swift
////  
////
////  Created by Woodrow Melling on 5/24/23.
////
//
//import Foundation
//import SwiftUI
//import Components
//
//public extension View {
//    func toolbarDateSelector(selectedDate: Binding<CalendarDate>) -> some View {
//        self.modifier(ToolbarDateSelectorViewModifier(selectedDate: selectedDate))
//    }
//}
//
//struct ToolbarDateSelectorViewModifier: ViewModifier {
//    @Binding var selectedDate: CalendarDate
//    @Environment(\.event) var event
//    
//    func body(content: Content) -> some View {
//        if #available(iOS 16, *) {
//            content
//                .navigationTitle(Text(FestivlFormatting.weekdayFormat(for: selectedDate)))
//                .toolbarTitleMenu {
//                    ForEach(event.festivalDates, id: \.self) { date in
//                        Button {
//                            selectedDate = date
//                        } label: {
//                            Text(FestivlFormatting.weekdayFormat(for: date))
//                        }
//                    }
//                }
//                .navigationBarTitleDisplayMode(.inline)
//        } else {
//            content
//                .toolbar {
//                    ToolbarItem(placement: .principal) {
//                        Menu {
//                            ForEach(event.festivalDates, id: \.self) { date in
//                                Button {
//                                    selectedDate = date
//                                } label: {
//                                    Text(FestivlFormatting.weekdayFormat(for: date))
//                                }
//                            }
//                        } label: {
//                            HStack {
//                                Text(FestivlFormatting.weekdayFormat(for: selectedDate))
//                                    .font(.title2)
//                                Image(systemName: "chevron.down")
//                                
//                            }
//                            .foregroundColor(.primary)
//                        }
//                    }
//                }
//        }
//    }
//}
