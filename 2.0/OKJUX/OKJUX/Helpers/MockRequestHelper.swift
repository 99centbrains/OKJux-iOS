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

    private static var mockRequestItems = [MockRequestItem: OHHTTPStubsDescriptor]()

    private enum MockRequest: Int {
        case post_register_user = 1
        case get_newest_snaps = 2
        case get_newest_snaps_error_500 = 3
        case get_newest_snaps_empty_result = 4
        case get_hottest_snaps = 5
        case post_snap_reported_succeeded = 6
        case post_snap_reported_fail = 7
        case post_snap_reported_already_reported = 8
    }

    class func mockRequest(path: String, responseFile: String, statusCode: Int32 = 200) {
        #if DEBUG
        _ = stub(condition: isPath(path)) { _ in
            if !responseFile.characters.isEmpty {
                let stubPath = OHPathForFile("MockFiles/\(responseFile).json", self)
                return OHHTTPStubsResponse(fileAtPath: stubPath!, statusCode: statusCode, headers: ["Content-Type": "application/json; charset=utf-8"])
            }
            return OHHTTPStubsResponse(jsonObject: [], statusCode: statusCode, headers: ["Content-Type": "application/json; charset=utf-8"])
        }
        #endif
    }

        class func mockRequest(mockRequestItem: MockRequestItem) {
            #if DEBUG
                guard let path: String = mockRequestItem.requestPath,
                    let responseFile: String = mockRequestItem.responseFileName,
                    let statusCode: Int32 = mockRequestItem.responseHTTPCode else {
                        return
                }

                let stubDescriptor = stub(condition: isPath(path)) { _ in
                    if mockRequestItem.removeAfterCalled {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            OHHTTPStubs.removeStub(mockRequestItems[mockRequestItem]!)
                        })
                    }
                    if !responseFile.characters.isEmpty {
                        let stubPath = OHPathForFile("MockFiles/\(responseFile).json", self)
                        return OHHTTPStubsResponse(fileAtPath: stubPath!, statusCode: statusCode, headers: ["Content-Type": "application/json; charset=utf-8"])
                    }
                    return OHHTTPStubsResponse(jsonObject: [], statusCode: statusCode, headers: ["Content-Type": "application/json; charset=utf-8"])
                }
                mockRequestItems[mockRequestItem] = stubDescriptor

            #endif
        }

    private class func mockRequest(request: MockRequest?) {
        guard let request = request else {
            return
        }
        switch request {
        case .post_register_user:
            mockRequest(path: "/api/v1/users", responseFile: "post_user_mock")
            break
        case .get_newest_snaps:
            mockRequest(path: "/api/v1/snaps", responseFile: "get_snaps_mock")
            break
        case .get_newest_snaps_error_500:
            mockRequest(path: "/api/v1/snaps", responseFile: "get_snaps_mock", statusCode: 500)
            break
        case .get_newest_snaps_empty_result:
            mockRequest(path: "/api/v1/snaps", responseFile: "get_snaps_empty_mock")
            break
        case .get_hottest_snaps:
            mockRequest(path: "/api/v1/snaps", responseFile: "get_hottest_snaps_mock")
            break
        case .post_snap_reported_succeeded:
            mockRequest(path: "/api/v1/snaps/13666/flag", responseFile: "", statusCode: 204)
            break
        case .post_snap_reported_fail:
            mockRequest(path: "/api/v1/snaps/13666/flag", responseFile: "", statusCode: 500)
            break
        case .post_snap_reported_already_reported:
            mockRequest(path: "/api/v1/snaps/13666/flag", responseFile: "", statusCode: 422)
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
