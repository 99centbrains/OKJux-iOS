//
//  UsersNetworkManager.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation
import Alamofire

class UsersNetworkManager: BasicNetworkManager {

    class func registerUser(parameters: [String: Any], completion: @escaping (Bool, [String: Any]?) -> Void) {

        sendRequest(method: "users", requestMethodType: .post, parameters: parameters) { (result, json) in
            if let json = json, result {
                if json.count > 0 {
                    completion(true, json)
                } else {
                    completion(false, nil)
                }
            } else {
                completion(false, nil)
            }
        }

    }
}
