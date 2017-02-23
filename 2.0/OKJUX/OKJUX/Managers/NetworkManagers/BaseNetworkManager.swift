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

class OKJuxError: NSError {

    enum ErrorType: Int {
        case unknown = 1
        case emptyResponseBody
        case notParsableResponse
        case loginRequired
        case noInternet

        var description: String {
            switch self {
            case .unknown:
                return "Something went wrong"
            case .emptyResponseBody, .notParsableResponse, .loginRequired:
                return "Server didn't response a correct answer"
            default:
                return "Something went wrong"
            }
        }
    }

    init<T>(errorType: ErrorType, generatedClass: T.Type) {
        super.init(domain: "com.okjux." + NSStringFromClass(generatedClass as! AnyClass), code: errorType.rawValue, userInfo: ["description" : errorType.description])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class BaseNetworkManager {

    static var basicURLComponents: NSURLComponents {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = ConfigurationManager.serverProtocol
        urlComponents.host = ConfigurationManager.serverHost
        return urlComponents
    }

    class func sendRequest(method: String,
                           requestMethodType: RequestMethodType = .get,
                           version: String = "v1",
                           parameters: [String: Any]? = nil,
                           completion: @escaping (NSError?, [String: Any]?) -> Void) {

        let urlComponents = self.basicURLComponents
        urlComponents.path = "/api/\(version)/\(method)"

        guard let url = urlComponents.url else {
            completion(OKJuxError(errorType: .unknown, generatedClass: type(of: self)), nil)
            return
        }

        Alamofire.request(url, method: HTTPMethod(rawValue: requestMethodType.rawValue)!, parameters: parameters).responseJSON { (response) in
            guard response.result.error == nil else {
                completion(OKJuxError(errorType: .noInternet, generatedClass: self), nil)
                return
            }

            if let json = response.result.value as? [String: Any], response.result.isSuccess {
                if let statusCode = response.response?.statusCode, statusCode < 200 || statusCode > 300 {
                    completion(OKJuxError(errorType: .unknown, generatedClass: self), nil)
                } else {
                    completion(nil, json)
                }
            } else {
                completion(OKJuxError(errorType: .unknown, generatedClass: self), nil)
            }
        }

    }

}
