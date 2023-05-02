//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/21/23.
//

import Foundation
import SwiftUI
import CoreMotion
import Models
import Components

struct ScheduleComingSoonView: View {
    var imageURL: URL?
    
    @State var degrees: Angle = .degrees(0)
    
    var body: some View {
        ZStack {
            
            
            CachedAsyncImage(url: imageURL, renderingMode: .template) {
                ProgressView()
            }
//            .frame(square: 300)
//            .foregroundColor(.label)
//            .rotationEffect(degrees)
////            .animation(.spring(), value: degrees)
//            .task {
//                while true {
//
//                    let animationDuration: Double = .random(in: 4...10)
//                    withAnimation(.easeInOut(duration: animationDuration)) {
//                        degrees += .degrees(.random(in: -360...360))
//                    }
//
//                    _ = try? await Task.sleep(nanoseconds: UInt64(animationDuration) * NSEC_PER_SEC)
//                }
//            }
 
            Color.systemBackground
                .opacity(0.6)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.thinMaterial)
            
            
            VStack {
                CachedAsyncImage(url: imageURL, renderingMode: .template) {
                    ProgressView()
                }
                .frame(square: 200)
                .foregroundColor(.label)
//                .shadow(radius: 5, .quaternaryLabel)
                
                
                Text("Schedule Coming Soon!")
                    .font(.title)
    //                    .fontWeight(.heavy)
                    
            }
            .shadow()
        }
        
        

            
    }
}


struct ScheduleComingSoonView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleComingSoonView(imageURL: Event.testData.imageURL)
    }
}

