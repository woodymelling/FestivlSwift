//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/24/23.
//

import Foundation
import SwiftUI

public struct NavigationArrow: View {

    public init() {}

    @ScaledMetric var height = 12
    public var body: some View {
        Image(systemName: "chevron.forward")
            .resizable()
            .foregroundStyle(.tertiary)
            .aspectRatio(contentMode: .fit)
            .fontWeight(.bold)
            .frame(height: self.height)
    }
}

struct NavigationLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            NavigationArrow()
        }
    }
}

public extension View {
    func navigationLinkButtonStyle() -> some View {
        HStack {
            self
            NavigationArrow()
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
                .navigationLinkButtonStyle()
            }
        }
    }
}
