//
//  SnapsManager.swift
//  OKJUX
//
//  Created by German Pereyra on 2/10/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation

class SnapsManager {

    static let sharedInstance = SnapsManager()

    func getSnaps(hottest: Bool = false, page: Int = 1,
                  latitude: Double? = nil, longitude: Double? = nil,
                  radius: Double = 80.450, completion: @escaping (NSError?, [Snap]?) -> Void) {

        guard let loggedUser = UserManager.sharedInstance.loggedUser else {
            completion(OKJuxError(errorType: OKJuxError.ErrorType.loginRequired, generatedClass: type(of: self)), nil)
            return
        }

        var parameters = [String: Any]()
        parameters["type"] = hottest ? "top" : "newest"
        parameters["user_id"] = loggedUser.identifier
        parameters["page"] = page
        if let lat = latitude, let lng = longitude {
            parameters["lat"] = lat
            parameters["lng"] = lng
            parameters["radius"] = radius
        }

        SnapsNetworkManager.getSnaps(parameters: parameters) { (error, json) in
            guard error == nil else {
                completion(error!, nil)
                return
            }

            if let json = json, let snaps = json["snaps"] as? [[String: Any]] {
                var snapsResult = [Snap]()
                for snapData in snaps {
                    if let snap = Snap(json: snapData) {
                        snapsResult.append(snap)
                    }
                }
                completion(nil, snapsResult)
            } else {
                completion(OKJuxError(errorType: OKJuxError.ErrorType.notParsableResponse, generatedClass: type(of: self)), nil)
            }

        }
    }

    func reportSnap(snap: Snap, completion: @escaping (NSError?) -> Void) {

        guard let loggedUser = UserManager.sharedInstance.loggedUser else {
            completion(OKJuxError(errorType: OKJuxError.ErrorType.loginRequired, generatedClass: type(of: self)))
            return
        }

        var parameters = [String: Any]()
        parameters["user"] = ["id": loggedUser.identifier, "UUID": loggedUser.uuid ?? ""]
        SnapsNetworkManager.reportSnap(snapID: snap.identifier, parameters: parameters, completion: completion)
    }

    func likeSnap(snap: Snap, like: Bool, completion: @escaping (NSError?) -> Void) {

        guard let loggedUser = UserManager.sharedInstance.loggedUser else {
            completion(OKJuxError(errorType: OKJuxError.ErrorType.loginRequired, generatedClass: type(of: self)))
            return
        }

        var parameters = [String: Any]()
        parameters["user"] = ["id": loggedUser.identifier, "UUID": loggedUser.uuid ?? ""]
        SnapsNetworkManager.likeSnap(snapID: snap.identifier, like: like, parameters: parameters, completion: completion)
    }

}
