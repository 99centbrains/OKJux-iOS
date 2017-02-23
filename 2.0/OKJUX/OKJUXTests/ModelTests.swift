//
//  ModelTests.swift
//  OKJUX
//
//  Created by German Pereyra on 2/21/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import XCTest
@testable import OKJUX

class ModelTests: XCTestCase {

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
            if let snapImage = SnapImage(json: jsonSnapImage) {
                XCTAssert(true)
            } else {
                XCTAssert(false, "snap must show the thumbnail if there is no image")
            }
        } else {
            XCTAssert(false, "unable to load mock")
        }

        if let json = loadMock(mockName: "snapImage_withoutThumbnai"), let jsonSnapImage = json["image"] as? [String: Any] {
            if let snapImage = SnapImage(json: jsonSnapImage) {
                XCTAssert(true)
            } else {
                XCTAssert(false, "snap must show the image if there is no thumbnail")
            }
        } else {
            XCTAssert(false, "unable to load mock")
        }
    }

    func test_snapConstructor() {
        if let json = loadMock(mockName: "snap"), let jsonSnaps = json["snaps"] as? [[String: Any]], let firstSnap = jsonSnaps.first {
            if let _ = Snap(json: firstSnap) {
                XCTAssert(true)
            } else {
                XCTAssert(false, "unable to parse the json when constructing a snap")
            }
        }
    }
}
