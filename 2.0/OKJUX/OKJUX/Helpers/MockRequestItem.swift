//
//  MockRequestItem.swift
//  OKJUX
//
//  Created by German Pereyra on 2/28/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import Foundation
import EVReflection

class MockRequestItem: EVObject {
    var requestPath: String?
    var responseFileName: String?
    var removeAfterCalled: Bool = false
    var responseHTTPCode: Int32?

    convenience init(requestPath: String, responseFileName: String) {
        self.init()
        self.requestPath = requestPath
        self.responseFileName = responseFileName
    }
}
