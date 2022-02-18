//
//  SwiftUIView.swift
//  
//
//  Created by Woody on 2/13/22.
//

import SwiftUI
import Utilities

struct ArtistLinkView: View {

    enum LinkType {
        case soundcloud, spotify, website

        var icon: Image {
            switch self {
            case .soundcloud:
                return Image("soundcloud", bundle: .module)
            case .spotify:
                return Image("spotify", bundle: .module)
            case .website:
                return Image(systemName: "globe")
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

    var body: some View {
        HStack {
            linkType.icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            Text(linkType.name)
            Spacer()
            NavigationLink.empty
        }
    }
}

struct ArtistLinkView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ArtistLinkView(linkType: .website)

            ArtistLinkView( linkType: .soundcloud)

            ArtistLinkView( linkType: .spotify)
        }
        .previewAllColorModes()
        .previewLayout(.sizeThatFits)
    }
}
