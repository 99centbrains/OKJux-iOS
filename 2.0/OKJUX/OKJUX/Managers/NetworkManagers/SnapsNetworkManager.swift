//
//  SnapsNetworkManager.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation

class SnapsNetworkManager: BaseNetworkManager {

    class func getSnaps(parameters: [String: Any], completion: @escaping (NSError?, [String: Any]?) -> Void) {

        sendRequest(method: "snaps", parameters: parameters) { (error, json) in
            guard error == nil else {
                completion(error!, nil)
                return
            }

            if let json = json, json.count > 0 {
                completion(nil, json)
            } else {
                completion(OKJuxError(errorType: OKJuxError.ErrorType.notParsableResponse, generatedClass: type(of: self)), nil)
            }
        }

    }
}
