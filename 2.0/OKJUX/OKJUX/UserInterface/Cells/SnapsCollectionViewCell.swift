//
//  SnapsCollectionViewCell.swift
//  OKJUX
//
//  Created by German Pereyra on 2/22/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import CoreLocation
import Neon
import SDWebImage

class SnapsCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier: String = "SnapsCollectionViewCell"

    var image: UIImageView!
    var loveIt: UIButton!
    var likesCount: UILabel!
    var reportAbuse: UIButton!
    var locationAndTimeAgo: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        loveIt = UIButton(type: .custom)
        contentView.addSubview(loveIt)
        loveIt.setImage(R.image.snap_heart_like(), for: .normal)
        loveIt.accessibilityLabel = "I like it"
        loveIt.anchorInCorner(.topLeft, xPad: 20, yPad: 20, width: 40, height: 40)

        likesCount = UILabel()
        contentView.addSubview(likesCount)
        likesCount.font = UIFont.systemFont(ofSize: 29)
        likesCount.shadowColor = .black
        likesCount.shadowOffset = CGSize(width: 2, height: 1)
        likesCount.textColor = .white
        likesCount.accessibilityLabel = "Likes count"
        likesCount.align(.toTheRightCentered, relativeTo: loveIt, padding: 10, width: 110, height: 45)

        reportAbuse = UIButton(type: .custom)
        contentView.addSubview(reportAbuse)
        reportAbuse.accessibilityLabel = "Report abuse"
        reportAbuse.setImage(R.image.snap_report_abuse(), for: .normal)
        reportAbuse.anchorInCorner(.topRight, xPad: 10, yPad: 10, width: 44, height: 44)

        locationAndTimeAgo = UILabel()
        contentView.addSubview(locationAndTimeAgo)
        locationAndTimeAgo.minimumScaleFactor = 0.4
        locationAndTimeAgo.adjustsFontSizeToFitWidth = true
        locationAndTimeAgo.font = UIFont.systemFont(ofSize: 12)
        locationAndTimeAgo.alignBetweenHorizontal(align: .toTheRightMatchingTop, primaryView: likesCount, secondaryView: reportAbuse, padding: 10, height: 20)

        image = UIImageView(frame: bounds)
        contentView.insertSubview(image, at: 0)
        image.contentMode = .scaleAspectFill
        image.accessibilityLabel = "Snap photo"
        image.backgroundColor = UIColor(patternImage: R.image.common_background_transparent()!)
        image.clipsToBounds = true

        //TODO: likes doesnt have an action yet
        //TODO: reportAbuse doesn't have an action yet
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadData(snap: Snap, hottest: Bool) {
        likesCount.text = String(snap.likescount)
        likesCount.accessibilityValue = String(snap.likescount)
        locationAndTimeAgo.text = ""
        if !hottest {
            setTimeAndLocation(snap: snap)
        } else {
            reportAbuse.isHidden = true
            locationAndTimeAgo.isHidden = true
        }

        let thumbnailURL = URL(string: snap.snapImage.thumbnailURL)

        self.image.sd_setImage(with: thumbnailURL, placeholderImage: nil, options: SDWebImageOptions.highPriority) { (img, error, cache, url) in
            self.image.image = img
            let realImageURL = URL(string: snap.snapImage.imageURL)
            self.image.sd_setImage(with: realImageURL, placeholderImage: img, options: SDWebImageOptions.highPriority) { (img, error, cache, url) in
                self.image.image = img
            }
        }

    }

    private func setTimeAndLocation(snap: Snap) {
        let strTimeAgo = "🕑 \(timeAgoSince(snap.createdAt))"
        let location = CLLocation(latitude: snap.location.0, longitude: snap.location.1)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { [weak self] (placemarks, error) -> Void in

            guard let placemarks = placemarks,
                let pm = placemarks.first,
                let country = pm.country,
                let city = pm.locality,
                error == nil else {
                    if let error = error {
                        print("Reverse geocoder failed with error" + error.localizedDescription)
                    }
                    self?.locationAndTimeAgo.text = strTimeAgo
                    self?.locationAndTimeAgo.accessibilityValue = strTimeAgo
                    self?.locationAndTimeAgo.accessibilityLabel = "Snap location and time ago"
                    return
            }

            self?.locationAndTimeAgo.text = String(format: "%@  📍 %@ - %@", strTimeAgo, country, city)
            self?.locationAndTimeAgo.accessibilityValue = self?.locationAndTimeAgo.text
            self?.locationAndTimeAgo.accessibilityLabel = "Snap location and time ago"
        })
    }
}
