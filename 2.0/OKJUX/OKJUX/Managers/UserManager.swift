//
//  UserManager.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation

class UserManager {

    static let sharedInstance = UserManager()

    var loggedUser: User?

    func registerUser(uuid: String?, completion: @escaping (Bool) -> Void) {

        let parameters = ["user[UUID]": UserHelper.getUUID()]

        BasicNetworkManager().sendPostRequest(method: "users", parameters: parameters) { (result, json) in
            if let json = json, result {
                if json.count > 0 {
                    if let user = json["user"] as? [String: Any], let id = user["id"] as? Double, let uuid = user["UUID"] as? String, let karma = user["karma"] as? Int {
                        self.loggedUser = User(id: id, uuid: uuid, karma: karma)
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }

    }
}
