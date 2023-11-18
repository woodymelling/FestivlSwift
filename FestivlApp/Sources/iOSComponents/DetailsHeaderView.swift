//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/28/23.
//

import Foundation
import SwiftUI
import Models
import Utilities
import Components

public struct DetailsHeaderView<Content: View>: View {
    public init(imageURL: URL? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.imageURL = imageURL
        self.content = content
    }
    
    var imageURL: URL?
    var content: () -> Content
    

    private let initialHeight = UIScreen.main.bounds.height / 2.5
    
    @Environment(\.event.imageURL) var eventImageURL

    public var body: some View {
        ZStack(alignment: .bottom) {
            
            Group {
//                if let imageURL = imageURL {
//                    CachedAsyncImage(url: imageURL) { ProgressView() }
//                        .aspectRatio(contentMode: .fill)
//                } else {
//                    CachedAsyncImage(url: eventImageURL, renderingMode: .template) {
//                        ProgressView()
//                    }
//                }
            }
            .frame(height: initialHeight)
            .aspectRatio(contentMode: .fill)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemBackground),
                        .clear
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .overlay(alignment: .bottomLeading) {
                content()
            }
        }
        .frame(height: initialHeight)
        
    }
}


struct ArtistHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsHeaderView(imageURL: nil) {
            Text("Details")
        }
    }
}
