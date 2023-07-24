//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/24/23.
//

import Foundation
import SwiftUI

extension View {
    
    public func navigationLinkListButton() -> some View {
        self.modifier(NavigationLinkButtonStyle())
    }
}

struct NavigationLinkButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            NavigationLink {
               Rectangle()
                    .opacity(0)
            } label: {
                EmptyView()
            }

            content
                
        }
    }
}


#Preview {
    NavigationStack {
        
        List {
            ForEach(0...1, id: \.self) { _ in
                
                Button {
                    print("Pressed")
                } label: {
                    Text("Press Me")
                }
                .modifier(NavigationLinkButtonStyle())
            }
        }
    }
}
