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

        var nearBy = false
        if let _ = parameters["lat"], let _ = parameters["lng"] {
            nearBy = true
        }

        sendRequest(method: "snaps" + (nearBy ? "/nearby" : ""), parameters: parameters) { (error, json) in
            guard error == nil else {
                completion(error!, nil)
                return
            }

            if let json = json, !json.isEmpty {
                completion(nil, json)
            } else {
                completion(OKJuxError(errorType: OKJuxError.ErrorType.notParsableResponse, generatedClass: type(of: self)), nil)
            }
        }
    }

    class func reportSnap(snapID: Int, parameters: [String: Any], completion: @escaping (NSError?) -> Void) {

        sendRequest(method: String(format: "snaps/%i/flag", snapID), requestMethodType: .post, parameters: parameters) { (error, _) in
            guard error == nil else {
                completion(error!)
                return
            }
            completion(nil)
        }
    }
}
