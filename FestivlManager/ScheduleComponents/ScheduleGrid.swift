//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/22/23.
//

import Foundation
import SwiftUI

public struct ScheduleGrid<Content: View>: View {
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var content: () -> Content
    
    public var body: some View {
        ZStack {
            HStack {
                ScheduleHourLabelsView()
                    .zIndex(0)
                
                ZStack {
                    ScheduleHourLines()
                        .zIndex(0)
                    
                    content()
                        .frame(height: 1500)
                        .zIndex(10)
                }
            }
            
            TimeIndicatorView()
        }
        .ignoresSafeArea(edges: .trailing)
    }
}

#Preview {
    ScheduleGrid {
        
    }
    .frame(height: 1000)
}
