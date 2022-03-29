//
//  File.swift
//  
//
//  Created by Woodrow Melling on 3/29/22.
//

import Foundation
import SwiftUI
import Components

struct EventDaySelector: View {
    var title: String
    @Binding var selectedDate: Date
    var festivalDates: [Date]


    var body: some View {

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
