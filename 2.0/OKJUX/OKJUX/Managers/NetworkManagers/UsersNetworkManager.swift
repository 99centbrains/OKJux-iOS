//
//  UsersNetworkManager.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation
import Alamofire

class UsersNetworkManager: BaseNetworkManager {

    class func registerUser(parameters: [String: Any], completion: @escaping (NSError?, [String: Any]?) -> Void) {

        self.sendRequest(method: "users", requestMethodType: .post, parameters: parameters) { (error, json) in
            if let error = error {
                completion(error, nil)
                return
            }

            if let json = json {

                if !json.isEmpty {
                    completion(nil, json)
                } else {
                    completion(OKJuxError(errorType: .emptyResponseBody, generatedClass: type(of: self)), nil)
                }
            } else {
                completion(OKJuxError(errorType: .emptyResponseBody, generatedClass: type(of: self)), nil)
            }
        }
    }

}
