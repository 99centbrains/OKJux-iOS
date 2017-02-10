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

    func registerUser(uuid: String?, completion: @escaping (NSError?) -> Void) {

        let parameters = ["user[UUID]": UserHelper.getUUID()]
        UsersNetworkManager.registerUser(parameters: parameters) { (error, json) in
            guard error == nil else {
                completion(error!)
                return
            }

            if let json = json {
                if let user = json["user"] as? [String: Any] {
                    self.loggedUser = User(json: user)
                    completion(nil)
                } else {
                    completion(OKJuxError(errorType: .notParsableResponse, generatedClass: type(of: self)))
                }
            } else {
                completion(OKJuxError(errorType: .unknown, generatedClass: type(of: self)))
            }
        }

    }
}
