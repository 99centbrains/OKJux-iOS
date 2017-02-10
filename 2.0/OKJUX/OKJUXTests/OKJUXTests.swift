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

    func loadMock(mockName: String) -> [String: Any]? {
        if let path = Bundle(for: self.classForCoder).url(forResource: mockName, withExtension: "json") {
            if let jsonData = NSData(contentsOf: path) {
                do {
                    if let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    {
                        return jsonResult as? [String: Any]
                    }

                } catch {}

            }
        }
        return nil
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //MARK: Model Tests

    func test_userJsonConsuctor() {
        var json: [String: Any] = [:]
        if let _ = User(json: json) {
            XCTAssert(false, "empty json must return a nil user")
        }
        json = ["id": 1254386]
        if let _ = User(json: json) {
            XCTAssert(false, "json without all the required values must return a nil user")
        }

        if let json = loadMock(mockName: "user"), let jsonUser = json["user"] as? [String: Any] {
            if let _ = User(json: jsonUser) {
                XCTAssert(true)
            } else {
                XCTAssert(false, "the json is ok and it was not able to map it")
            }
        } else {
            XCTAssert(false, "unable to load mock")
        }
    }

    func test_snapImageJsonConsuctor() {
        var json: [String: Any] = [:]
        if let _ = SnapImage(json: json) {
            XCTAssert(false, "empty json must return a nil user")
        }
        json["image"] = [:]
        if let _ = SnapImage(json: json) {
            XCTAssert(false, "empty json must return a nil user")
        }
        json["image"] = ["id": 1254386]
        if let _ = SnapImage(json: json) {
            XCTAssert(false, "json without all the required values must return a nil user")
        }

        if let json = loadMock(mockName: "snapImage"), let jsonUser = json["image"] as? [String: Any] {
            if let _ = SnapImage(json: jsonUser) {
                XCTAssert(true)
            } else {
                XCTAssert(false, "the json is ok and it was not able to map it")
            }
        } else {
            XCTAssert(false, "unable to load mock")
        }
    }

    func test_snapWithoutImage() {
        if let json = loadMock(mockName: "snapImage_withoutImage"), let jsonSnapImage = json["image"] as? [String: Any] {
            if let snapImage = SnapImage(json: jsonSnapImage), let _ = snapImage.imageURL, let _ = snapImage.thumbnailURL {
                XCTAssert(true)
            } else {
                XCTAssert(false, "snap must show the thumbnail if there is no image")
            }
        } else {
            XCTAssert(false, "unable to load mock")
        }

        if let json = loadMock(mockName: "snapImage_withoutThumbnai"), let jsonSnapImage = json["image"] as? [String: Any] {
            if let snapImage = SnapImage(json: jsonSnapImage), let _ = snapImage.imageURL, let _ = snapImage.thumbnailURL {
                XCTAssert(true)
            } else {
                XCTAssert(false, "snap must show the image if there is no thumbnail")
            }
        } else {
            XCTAssert(false, "unable to load mock")
        }
    }

    //MARK: Managers Tests
    
    func test_registerUserPostRequest() {
        let exp = expectation(description: "")
        BasicNetworkManager.sendRequest(method: "users", requestMethodType: .post, parameters: ["user[UUID]": "F96034AC-446E-4139-949D-9F7CB4686322"]) { (error, json) in

            guard error == nil else {
                XCTAssert(false, "request faild")
                exp.fulfill()
                return
            }

            if let json = json {
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
        UserManager.sharedInstance.registerUser(uuid: UserHelper.getUUID(), completion: { error in
            if error == nil {
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
