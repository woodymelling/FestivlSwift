//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/22/23.
//

import SwiftUI
import ComposableArchitecture
import ScheduleComponents

struct WorkshopsView: View {
    let store: StoreOf<WorkshopsDomain>
    
    var body: some View {
        
        ScrollView {
            TabView {
                ScheduleHourLabelsView()
                ScheduleHourLabelsView()
                ScheduleHourLabelsView()
            }
            .frame(height: 1000)
        }
        .tabViewStyle(.page)
    }
}


struct WorkshopsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkshopsView(
            store: .init(
                initialState: .init(
                    selectedDate: .today,
                    workshops: [:]),
                reducer: WorkshopsDomain()
            )
        )
    }
}

