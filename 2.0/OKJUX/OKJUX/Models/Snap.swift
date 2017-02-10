//
//  Snap.swift
//  OKJUX
//
//  Created by German Pereyra on 2/10/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation

class Snap {

    var id: Int!
    var location: (Double, Double)!
    var hidden: Bool!
    var createdAt: NSDate!
    var flagsCount: Int!
    var likescount: Int!
    var reported: Bool!
    var user: User!
    var snapImage: SnapImage!

    init?(id: Int?, location: (Double?, Double?)?, hidden: Bool? = false, createdAt: NSDate?, flagsCount: Int? = 0, likescount: Int? = 0, reported: Bool? = false, user: User?, snapImage: SnapImage?) {
        guard let id = id, let location = location, let latitude = location.0, let longitude = location.1, let createdAt = createdAt, let user = user, let snapImage = snapImage else {
            return nil
        }
        self.id = id
        self.location = (latitude, longitude)
        self.hidden = hidden
        self.createdAt = createdAt
        self.flagsCount = flagsCount
        self.likescount = likescount
        self.reported = reported
        self.user = user
        self.snapImage = snapImage
    }

}

class SnapImage {

    private var _thumbnailURL: String?
    private var _imageURL: String?

    var thumbnailURL: String? {
        if let _  = _thumbnailURL {
            return _thumbnailURL
        }
        return _imageURL
    }

    var imageURL: String? {
        if let _ = _imageURL {
            return _imageURL
        }
        return _thumbnailURL
    }

    init?(imageURL: String?, thumbnailURL: String?) {
        guard imageURL != nil || thumbnailURL != nil else {
            return nil
        }
        _thumbnailURL = thumbnailURL
        _imageURL = imageURL
    }

    convenience init?(json: [String: Any]) {
        guard let image = json["image"] as? [String: Any] else {
            return nil
        }
        if let thumb = image["thumbnail"] as? [String: Any], let thumbUrl = thumb["url"] {
            self.init(imageURL: image["url"] as? String, thumbnailURL: thumbUrl as? String)
        } else {
            self.init(imageURL: image["url"] as? String, thumbnailURL: nil)
        }
    }
}
