//
//  BasicNetworkManager.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation
import Alamofire

enum RequestMethodType: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
    case put = "PUT"
}

class BasicNetworkManager {

    static var basicURLComponents: NSURLComponents {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = ConfigurationManager.serverProtocol
        urlComponents.host = ConfigurationManager.serverHost
        return urlComponents
    }

    class func sendRequest(method: String, requestMethodType: RequestMethodType = .get, version: String = "v1", parameters: [String: Any]? = nil, completion: @escaping (_ result: Bool, _ json: [String : Any]?) -> Void) {

        let urlComponents = self.basicURLComponents
        urlComponents.path = "/api/\(version)/\(method)"

        guard let url = urlComponents.url else {
            completion(false, nil)
            return
        }

        Alamofire.request(url, method: HTTPMethod(rawValue: requestMethodType.rawValue)!, parameters: parameters).responseJSON { (response) in
            if let json = response.result.value as? [String: Any], response.result.isSuccess {
                completion(true, json)
            } else {
                completion(false, nil)
            }
        }

    }

}
