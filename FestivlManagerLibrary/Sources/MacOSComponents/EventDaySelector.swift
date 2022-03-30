//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/29/22.
//

import Foundation
import SwiftUI
import Components

public struct EventDaySelector: View {
    public init(title: String, selectedDate: Binding<Date>, festivalDates: [Date]) {
        self.title = title
        self._selectedDate = selectedDate
        self.festivalDates = festivalDates
    }

    var title: String
    @Binding var selectedDate: Date
    var festivalDates: [Date]


    public var body: some View {

        Picker(title, selection: $selectedDate, content: {
            ForEach(festivalDates, id: \.self, content: { date in
                Text(FestivlFormatting.weekdayWithDatesFormat(for: date)).tag(date)
            })
        })
    }
}

struct FestivalDaySelector_Previews: PreviewProvider {
    static var previews: some View {
        EventDaySelector(title: "Date Selector", selectedDate: .constant(Date()), festivalDates: [Date.now])
    }
}
