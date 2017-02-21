    //
//  MockRequestHelper.swift
//  OKJUX
//
//  Created by German Pereyra on 2/21/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation
import OHHTTPStubs

class MockRequestHelper {

    private enum MockRequest: Int {
        case post_register_user = 1
        case get_newest_snaps = 2
    }

    class func mockRequest(path: String, responseFile: String) {
        #if DEBUG
        _ = stub(condition: isPath(path)) { _ in
            let stubPath = OHPathForFile("MockFiles/\(responseFile).json", self)
            return OHHTTPStubsResponse(fileAtPath: stubPath!, statusCode: 200, headers: ["Content-Type": "application/json; charset=utf-8"])
        }
        #endif
    }

    private class func mockRequest(request: MockRequest?) {
        guard let request = request else {
            return
        }
        switch request {
        case .get_newest_snaps:
            mockRequest(path: "/api/v1/snaps", responseFile: "get_snaps_mock")
            break
        case .post_register_user:
            mockRequest(path: "/api/v1/users", responseFile: "post_user_mock")
            break
        }
    }

    class func mockAppByString(_ str: String) -> [Int] {
        var mockIds = [Int]()
        if str.contains("Mock") {
            let mocks = str.replacingOccurrences(of: "Mock-", with: "").components(separatedBy: ",")
            for strMock in mocks {

                if let mockRequest = MockRequest(rawValue: Int(strMock) ?? 0) {
                    self.mockRequest(request: mockRequest)
                    mockIds.append(mockRequest.rawValue)
                }
            }
        }
        return mockIds
    }

}
