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
        HStack(alignment: .top) {
            Rectangle()
                .fill(color)
                .frame(width: 5)
                
            GeometryReader { _ in
                content()
            }
        }
        .foregroundColor(color)
//        .overlay {
//            if isSelected {
//                Rectangle()
//                    .stroke(.white, lineWidth: 1)
////                    .glow(color: .white, radius: 2)
//            }
//        }
        .background {
            Rectangle()
                .fill(color.opacity(0.30))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))

    }
}

struct ScheduleCardBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleCardBackground(color: .red) {
            VStack(alignment: .leading) {
                Text("Blah")
            }
        }
        .frame(width: 200, height: 100)
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
