//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/28/23.
//

import Foundation
import SwiftUI
import Models
import iOSComponents
import Components

struct WorkshopDetailsView: View {
    
    var workshop: Workshop
    
    var body: some View {
        NavigationView {
            VStack {
                DetailsHeaderView(imageURL: workshop.imageURL) {
                    VStack(alignment: .leading) {
                        Text(workshop.name)
                            .font(.system(size: 30))
                        
                        if let instructorName = workshop.instructorName {
                            
                            Text(instructorName)
                                .font(.body)
                                .bold()
                            
                        }
                    }
                    .padding()
                }
                
                List {
                    WorkshopTimeAndPlaceRow(workshop: workshop)
                
                    if let description = workshop.description, !description.isEmpty {
                        Text(description)
                    }
                }
                .listStyle(.plain)
            }
            .edgesIgnoringSafeArea(.top)
        }
        
        
    }
}

private struct WorkshopTimeAndPlaceRow: View {
    let workshop: Workshop
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(
                FestivlFormatting.timeIntervalFormat(
                    startTime: workshop.startTime,
                    endTime: workshop.endTime
                )
            )
            
            Text(FestivlFormatting.timeOfDayFormat(for: workshop.startTime))
                .font(.callout)
            
            Text(
                workshop.location
            )
            .font(.caption)
            .foregroundColor(.secondaryLabel)
        }
    }
}

struct WorkshopDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkshopDetailsView(workshop: Workshop.testValue)
    }
}
