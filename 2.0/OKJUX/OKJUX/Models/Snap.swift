//
//  Snap.swift
//  OKJUX
//
//  Created by German Pereyra on 2/10/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation
import DateParser

class Snap {

    var identifier: Int!
    var location: (Double, Double)!
    var hidden: Bool!
    var createdAt: Date!
    var flagsCount: Int!
    var likescount: Int!
    var reported: Bool = false
    var user: User!
    var snapImage: SnapImage!

    init?(identifier: Int?,
          location: (Double?, Double?)?, hidden: Bool? = false,
          createdAt: Date?, flagsCount: Int? = 0, likescount: Int? = 0,
          reported: Bool? = false, user: User?, snapImage: SnapImage?) {

        guard let identifier = identifier,
            let location = location,
            let latitude = location.0,
            let longitude = location.1,
            let createdAt = createdAt,
            let user = user,
            let snapImage = snapImage else {
            return nil
        }
        self.identifier = identifier
        self.location = (latitude, longitude)
        self.hidden = hidden
        self.createdAt = createdAt
        self.flagsCount = flagsCount
        self.likescount = likescount
        self.reported = reported ?? false
        self.user = user
        self.snapImage = snapImage
    }

    convenience init?(json: [String: Any]) {

        var locationParsed: (Double?, Double?)?
        if let location = json["location"] as? [Double], location.count > 1 {
            locationParsed = (location.first!, location.last!)
        }

        var createdAtAux: Date?
        if let createdStr = json["created_at"] as? String {
            do {
            createdAtAux = try Date(dateString: createdStr)
            } catch {}
        }
        self.init(identifier: json["id"] as? Int,
                  location: locationParsed,
                  hidden: json["hidden"] as? Bool,
                  createdAt: createdAtAux,
                  flagsCount: json["flags_count"] as? Int,
                  likescount: json["likes_count"] as? Int,
                  reported: json["reported"] as? Bool,
                  user: User(json: json["user"] as? [String: Any]),
                  snapImage: SnapImage(json: json["image"] as? [String: Any]))
    }

}

class SnapImage {

    private var _thumbnailURL: String?
    private var _imageURL: String?

    var thumbnailURL: String {
        if let _  = _thumbnailURL {
            return _thumbnailURL!
        }
        return _imageURL!
    }

    var imageURL: String {
        if let _ = _imageURL {
            return _imageURL!
        }
        return _thumbnailURL!
    }

    init?(imageURL: String?, thumbnailURL: String?) {
        guard imageURL != nil || thumbnailURL != nil else {
            return nil
        }
        _thumbnailURL = thumbnailURL
        _imageURL = imageURL
    }

    convenience init?(json: [String: Any]?) {
        guard let json = json, let image = json["image"] as? [String: Any] else {
            return nil
        }
        if let thumb = image["thumbnail"] as? [String: Any], let thumbUrl = thumb["url"] {
            self.init(imageURL: image["url"] as? String, thumbnailURL: thumbUrl as? String)
        } else {
            self.init(imageURL: image["url"] as? String, thumbnailURL: nil)
        }
    }
}
