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

}
