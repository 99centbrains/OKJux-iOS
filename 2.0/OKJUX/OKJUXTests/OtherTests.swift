//
//  OtherTests.swift
//  OKJUX
//
//  Created by German Pereyra on 2/21/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import XCTest
@testable import OKJUX

class OtherTests: OKJUXTests {

    func test_mocksHelper() {
        XCTAssertTrue(MockRequestHelper.mockAppByString("").isEmpty)
        XCTAssertTrue(MockRequestHelper.mockAppByString("Mock").isEmpty)
        XCTAssertTrue(MockRequestHelper.mockAppByString("Mock-").isEmpty)
        XCTAssertTrue(MockRequestHelper.mockAppByString("Mock-0").isEmpty)
        XCTAssertTrue(MockRequestHelper.mockAppByString("Mock-1").count == 1)
        XCTAssertTrue(MockRequestHelper.mockAppByString("Mock-1,2").count == 2)
        XCTAssertTrue(MockRequestHelper.mockAppByString("Mock-99999,999998").isEmpty)
    }
    
}
