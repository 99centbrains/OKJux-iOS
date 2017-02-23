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

    func signInUser(completion: @escaping ()->Void) {
        UserManager.sharedInstance.registerUser(uuid: "F96034AC-446E-4139-949D-9F7CB4686322", completion: { error in
            if error == nil {
                if let user = UserManager.sharedInstance.loggedUser {
                    if user.id == 0 {
                        XCTAssert(false, "user was not mapped correctly")
                    }
                } else {
                    XCTAssert(false, "user still not logged in")
                }
            } else {
                XCTAssert(false, "something went wrong registering the user")
            }
            completion()
        })

    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    //MARK: Managers Tests
    
    


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
