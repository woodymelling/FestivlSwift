//
//  File.swift
//  
//
//  Created by Woody on 3/2/22.
//

import Foundation
import UIKit
import CollectionViewSlantedLayout
import Models

let yOffsetSpeed: CGFloat = 150.0
let xOffsetSpeed: CGFloat = 100.0

class ArtistExploreCell: CollectionViewSlantedCell {

    var imageView: UIImageView = UIImageView(frame: .zero)
//    var gradientView: GradientView = GradientView()
    var artistNameLabel = UILabel()
//    var stageIndicator = StageIndicatorView()
    var gradient = CAGradientLayer()

    var artist: Artist?

    override init(frame: CGRect) {
        super.init(frame: frame)
//
//        self.backgroundView = imageView
//        contentView.addSubview(gradientView)
        contentView.addSubview(artistNameLabel)
//        contentView.addSubview(stageIndicator)

        artistNameLabel.font = artistNameLabel.font.withSize(30)

        imageView.contentMode = .scaleAspectFill
        artistNameLabel.textAlignment = .center

//        imageView.image = FirebaseArtist.defaultImage
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    var imageHeight: CGFloat {
        return (imageView.image?.size.height) ?? 0.0
    }

    var imageWidth: CGFloat {
        return (imageView.image?.size.width) ?? 0.0
    }

    func offset(_ offset: CGPoint) {
        imageView.frame = imageView.bounds.offsetBy(dx: offset.x, dy: offset.y)
//        gradientView.layer.frame = gradientView.bounds
    }

    func initWithArtist(artist: Artist) {

        artistNameLabel.text = artist.name
        self.artist = artist
    }
}
