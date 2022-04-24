//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/13/22.
//

import SwiftUI
import Utilities
import SharedResources

struct ArtistLinkView: View {

    enum LinkType {
        case soundcloud, spotify, website

        var icon: Image {
            switch self {
            case .soundcloud:
                return SharedResources.LinkIcons.soundcloud
            case .spotify:
                return SharedResources.LinkIcons.spotify
            case .website:
                return SharedResources.LinkIcons.website
            }
        }

        var name: String {
            switch self {
            case .soundcloud:
                return "Soundcloud"
            case .spotify:
                return "Spotify"
            case .website:
                return "Website"
            }
        }
    }

//    var link: URL
    var linkType: LinkType
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap, label: {
            HStack {
                linkType.icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text(linkType.name)
                Spacer()
                NavigationLink.empty
            }
        })

    }
}

struct ArtistLinkView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ArtistLinkView(linkType: .website) {

            }

            ArtistLinkView(linkType: .soundcloud) { }

            ArtistLinkView(linkType: .spotify) { }
        }
        .previewAllColorModes()
        .previewLayout(.sizeThatFits)
    }
}
