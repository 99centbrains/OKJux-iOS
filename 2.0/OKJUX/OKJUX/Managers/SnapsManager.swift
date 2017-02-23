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

    func getSnaps(hottest: Bool = false, page: Int = 1, completion: @escaping (NSError?, [Snap]?) -> ()) {

        guard let loggedUser = UserManager.sharedInstance.loggedUser else {
            completion(OKJuxError(errorType: OKJuxError.ErrorType.loginRequired, generatedClass: type(of: self)), nil)
            return
        }

        var parameters = [String: Any]()
        parameters["type"] = hottest ? "top" : "newest"
        parameters["user_id"] = loggedUser.id
        parameters["page"] = page

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

}
