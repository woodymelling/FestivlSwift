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
import Kingfisher
import SwiftUI
import Components

let yOffsetSpeed: CGFloat = 150.0
let xOffsetSpeed: CGFloat = 100.0

class ArtistExploreCell: CollectionViewSlantedCell {

    var imageView: UIImageView = UIImageView(frame: .zero)
//    var gradientView: GradientView = GradientView()
    var artistNameLabel = UILabel()
    var stageIndicator = StageIndicatorUIView(frame: .zero)
    var gradient = UIHostingController(
        rootView: LinearGradient(
            colors: [Color(uiColor: .systemBackground), Color.clear],
            startPoint: .bottom,
            endPoint: .top
        )
    )

    var artist: Artist?

    override init(frame: CGRect) {
        super.init(frame: frame)
//
        self.backgroundView = imageView
        contentView.addSubview(gradient.view)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(stageIndicator)
//
        gradient.view.backgroundColor = .clear
        

        artistNameLabel.font = artistNameLabel.font.withSize(30)
        artistNameLabel.textAlignment = .center

        imageView.contentMode = .scaleAspectFill
        imageView.kf.indicatorType = .activity
        artistNameLabel.textAlignment = .center

//        let constraints = [
//            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//
//        ]
//
//        NSLayoutConstraint.activate(constraints)

//        imageView.image = FirebaseArtist.defaultImage

        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    func setUpConstraints() {
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        gradient.view.translatesAutoresizingMaskIntoConstraints = false
        stageIndicator.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            artistNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            artistNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -75),

            gradient.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradient.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradient.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradient.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 75),

            stageIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stageIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stageIndicator.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 10),
            stageIndicator.heightAnchor.constraint(equalToConstant: 5)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    var imageHeight: CGFloat {
        return (imageView.image?.size.height) ?? 0.0
    }

    var imageWidth: CGFloat {
        return (imageView.image?.size.width) ?? 0.0
    }

    func offset(_ offset: CGPoint) {

        guard offset.y.rounded(.towardZero) != 0 else { return }

        let newBounds = imageView.bounds.offsetBy(dx: offset.x, dy: offset.y)
        // Fix crash where newBounds contains NAN
        if newBounds.origin.x.isNaN {
            return
        }
        
        imageView.frame = newBounds
        gradient.view.layer.frame = gradient.view.bounds
    }

    func initWithArtist(artist: Artist, stages: [Stage]) {

        artistNameLabel.text = artist.name
        imageView.kf.setImage(with: artist.imageURL, options: [.processor(DownsamplingImageProcessor(size: imageView.frame.size)), .cacheOriginalImage])
        self.artist = artist
        stageIndicator.setStages(stages: stages)
    }

    override func prepareForReuse() {
//        stageIndicator.subviews.forEach {
//            $0.removeFromSuperview()
//        }
    }
}
