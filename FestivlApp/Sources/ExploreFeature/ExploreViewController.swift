//
//  File.swift
//
//
//  Created by Woody on 3/2/22.
//

import Foundation
import UIKit
import Models
import CollectionViewSlantedLayout
import SwiftUI
import Utilities
import ComposableArchitecture
import ArtistPageFeature

struct ExploreViewHosting: UIViewControllerRepresentable {
    var artists: IdentifiedArrayOf<ArtistPageState>
    var stages: IdentifiedArrayOf<Stage>
    var schedule: Schedule
    var onSelectArtist: (ArtistPageState) -> Void
    var favoriteArtists: Set<ArtistID>


    typealias UIViewControllerType = ExploreViewController

    func makeUIViewController(context: Context) -> ExploreViewController {
        ExploreViewController(
            exploreArtists: artists,
            stages: stages,
            schedule: schedule,
            onSelectArtist: onSelectArtist,
            favoriteArtists: favoriteArtists
        )
    }

    func updateUIViewController(_ vc: ExploreViewController, context: Context) {

        // Only reload data if the data actually changes
        if vc.exploreArtists != artists ||
            vc.stages != stages ||
            vc.schedule != schedule ||
            vc.favoriteArtists != favoriteArtists
        {
            vc.exploreArtists = artists
            vc.stages = stages
            vc.schedule = schedule
            vc.favoriteArtists = favoriteArtists

            print(artists)
            vc.collectionView.reloadData()
        }

    }
}

class ExploreViewController: UICollectionViewController {
    var exploreArtists: IdentifiedArrayOf<ArtistPageState>
    var stages: IdentifiedArrayOf<Stage>
    var schedule: Schedule
    var favoriteArtists: Set<ArtistID>
    var onSelectArtist: (ArtistPageState) -> Void

    let layout = CollectionViewSlantedLayout()

    init(
        exploreArtists: IdentifiedArrayOf<ArtistPageState>,
        stages: IdentifiedArrayOf<Stage>,
        schedule: Schedule,
        onSelectArtist: @escaping (ArtistPageState) -> Void,
        favoriteArtists: Set<ArtistID>
    ) {

        self.exploreArtists = exploreArtists
        self.stages = stages
        self.schedule = schedule
        self.onSelectArtist = onSelectArtist
        self.favoriteArtists = favoriteArtists

        super.init(collectionViewLayout: UICollectionViewLayout())

        collectionView.register(ArtistExploreCell.self, forCellWithReuseIdentifier: "ArtistExploreCell")
        collectionView.collectionViewLayout = layout

        layout.isFirstCellExcluded = true
        layout.isLastCellExcluded = true

        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl

        self.setContentScrollView(self.collectionView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        collectionView.contentInset = UIEdgeInsets(top: -view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
    
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        view.layoutIfNeeded()
        collectionView.reloadData()
    }

    // MARK: CollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exploreArtists.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: ArtistExploreCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistExploreCell", for: indexPath) as! ArtistExploreCell

        let artist = exploreArtists[indexPath.row].artist
        cell.initWithArtist(
            artist: artist,
            stages: schedule
                .scheduleItemsForArtist(artist: artist)
                .compactMap {
                    stages[id: $0.stageID]
                }
        )

        if let layout = collectionView.collectionViewLayout as? CollectionViewSlantedLayout {

            let angle = -tan(CGFloat(layout.slantingSize)/view.frame.width)
            cell.artistNameLabel.transform = CGAffineTransform(rotationAngle: angle)
            cell.stageIndicator.transform = CGAffineTransform(rotationAngle: angle)
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectArtist(exploreArtists[indexPath.row])
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView else {return}
        guard let visibleCells = collectionView.visibleCells as? [ArtistExploreCell] else {return}

        for parallaxCell in visibleCells {
            let yOffset = (collectionView.contentOffset.y - parallaxCell.frame.origin.y) / parallaxCell.imageHeight
            let xOffset = (collectionView.contentOffset.x - parallaxCell.frame.origin.x) / parallaxCell.imageWidth
            parallaxCell.offset(CGPoint(x: xOffset * xOffsetSpeed / 1.5, y: yOffset * yOffsetSpeed / 1.5))
        }
    }
}





extension ExploreViewController: CollectionViewDelegateSlantedLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: CollectionViewSlantedLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
}
