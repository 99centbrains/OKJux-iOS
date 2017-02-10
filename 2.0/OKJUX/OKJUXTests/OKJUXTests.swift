//
//  OKJUXTests.swift
//  OKJUXTests
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import XCTest
@testable import OKJUX

class OKJUXTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_registerUserPostRequest() {
        let exp = expectation(description: "")
        BasicNetworkManager.sendRequest(method: "users", requestMethodType: .post, parameters: ["user[UUID]": "F96034AC-446E-4139-949D-9F7CB4686322"]) { (result, json) in
            if let json = json, result {
                if json.count > 0 {
                    if let user = json["user"] as? [String: Any], let _ = user["id"] as? Double, let _ = user["UUID"] as? String, let _ = user["karma"] as? Int {
                        XCTAssert(true)
                    } else {
                        XCTAssert(false, "the parameters were not able to be casted")
                    }
                } else {
                    XCTAssert(false, "json result came empty")
                }
                exp.fulfill()
            } else {
                XCTAssert(false, "request faild")
            }
        }


        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_registerUser() {
        let exp = expectation(description: "")
        UserManager.sharedInstance.registerUser(uuid: UserHelper.getUUID(), completion: { result in
            if result {
                if let user = UserManager.sharedInstance.loggedUser {
                    if user.id != 0 {
                        XCTAssert(true, "registered correctly")
                    } else {
                        XCTAssert(false, "user was not mapped correctly")
                    }
                } else {
                    XCTAssert(false, "user still not logged in")
                }
            } else {
                XCTAssert(false, "something went wrong registering the user")
            }
            exp.fulfill()
        })

        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
