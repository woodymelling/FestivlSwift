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
        case soundcloud, spotify, website, instagram, youtube, facebook

        var icon: Image {
            switch self {
            case .soundcloud: return FestivlAssets.LinkIcons.soundcloud
            case .spotify: return FestivlAssets.LinkIcons.spotify
            case .website: return FestivlAssets.LinkIcons.website
            case .instagram: return FestivlAssets.LinkIcons.instagram
            case .facebook: return FestivlAssets.LinkIcons.facebook
            case .youtube: return FestivlAssets.LinkIcons.youtube
            }
        }

        var name: String {
            switch self {
            case .soundcloud: return "Soundcloud"
            case .spotify: return "Spotify"
            case .website: return "Website"
            case .instagram: return "Instagram"
            case .youtube: return "Youtube"
            case .facebook: return "Facebook"
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
            }
        })
        .navigationLinkListButton()
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
        .previewLayout(.sizeThatFits)
    }
}
