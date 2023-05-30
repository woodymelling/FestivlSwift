//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/22/23.
//

import Foundation
import SwiftUI
import Utilities

public struct ScheduleGrid<Content: View>: View {
    public init(content: @escaping () -> Content) {
        self.content = content
    }

    var content: () -> Content
    
    public var body: some View {
        ZStack {
            HStack {
                ScheduleHourLabelsView()
                
                ZStack {
                    ScheduleHourLines()
                    
                    content()
                        .frame(height: 1500)
                }
            }
            
            TimeIndicatorView()
        }
        .ignoresSafeArea(edges: .trailing)
    }
}
