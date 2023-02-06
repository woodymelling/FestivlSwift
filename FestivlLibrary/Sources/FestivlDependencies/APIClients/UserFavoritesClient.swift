//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/28/22.
//

import Foundation
import Models

struct UserFavoritesClient {
    let toggleArtistFavorite: (Artist.ID) -> Void
    let isArtistFavorited: (Artist.ID) -> Bool
}


