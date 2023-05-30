//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 5/24/23.
//

import SwiftUI

public struct ScheduleCardBackground<Content: View>: View {
    var isSelected: Bool
    var color: Color
    var content: () -> Content

    public init(color: Color, isSelected: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.isSelected = isSelected
        self.color = color
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(.white)
                .frame(height: 1)
                .opacity(0.25)

            HStack(alignment: .top) {
                Rectangle()
                    .fill(.white)
                    .frame(width: 5)
                    .opacity(0.25)
                
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .glow(color: isSelected ? .white : .clear, radius: 1)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .clipped()
        .frame(maxWidth: .infinity)
        .background(color)
        .overlay {
            if isSelected {
                Rectangle()
                    .stroke(.white, lineWidth: 1)
                    .glow(color: .white, radius: 2)
            }
        }
    }
}

struct ScheduleCardBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleCardBackground(color: .red) {
            Text("Title")
        }
    }
}

extension View {
    func glow(color: Color = .red, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
}
