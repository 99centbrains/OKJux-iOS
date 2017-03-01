//
//  MockRequestItem.swift
//  OKJUX
//
//  Created by German Pereyra on 2/28/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation

class MockRequestItem: NSObject {
    var requestPath: String?
    var responseFileName: String?
    var removeAfterCalled: Bool = false
    var responseHTTPCode: Int32?

    convenience init(requestPath: String, responseFileName: String, responseHTTPCode: Int32, removeAfterCalled: Bool = false) {
        self.init()
        self.requestPath = requestPath
        self.responseFileName = responseFileName
        self.responseHTTPCode = responseHTTPCode
        self.removeAfterCalled = removeAfterCalled
    }

    func toJsonString() -> String {
        return "{\"requestPath\": \"\(requestPath!)\", \"responseFileName\": \"\(responseFileName!)\", \"removeAfterCalled\": \(removeAfterCalled), \"responseHTTPCode\":   \(responseHTTPCode!)}"
    }

    convenience init?(jsonString: String) {
        guard let dict = MockRequestItem.convertToDictionary(text: jsonString),
            let requestPath = dict["requestPath"] as? String,
            let responseFileName = dict["responseFileName"] as? String,
            let removeAfterCalled = dict["removeAfterCalled"] as? Bool,
            let responseHTTPCode = dict["responseHTTPCode"] as? Int32 else {
                return nil
        }
        self.init(requestPath: requestPath, responseFileName: responseFileName, responseHTTPCode: responseHTTPCode, removeAfterCalled: removeAfterCalled)
    }

    static func convertToDictionary(text: String) -> [String: Any]? {
        print(text)
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

}
