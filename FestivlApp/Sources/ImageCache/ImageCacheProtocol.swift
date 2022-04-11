//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/9/22.
//

import Foundation
import UIKit

protocol ImageCacheDestination {
    // Returns the image associated with a given url
    func image(for url: URL, size: CGSize) -> UIImage?

    // Inserts the image of the specified url in the cache
    func insertImage(_ image: UIImage?, for url: URL, size: CGSize)

    // Removes the image of the specified url in the cache
    func removeImage(for url: URL, size: CGSize)

    // Removes all images from the cache
    func removeAllImages()

    // Accesses the value associated with the given key for reading and writing
    subscript(_ url: URL, size: CGSize) -> UIImage? { get set }
}


