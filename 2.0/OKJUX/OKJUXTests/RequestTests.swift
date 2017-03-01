//
//  RequestTests.swift
//  OKJUX
//
//  Created by German Pereyra on 2/21/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import XCTest
@testable import OKJUX

class RequestTests: OKJUXTests {

    func test_register_user_post_request() {
        let exp = expectation(description: "")
        BaseNetworkManager.sendRequest(method: "users",
                                       requestMethodType: .post,
                                       parameters: ["user[UUID]": "F96034AC-446E-4139-949D-9F7CB4686324"]) { (error, json) in

            guard error == nil else {
                XCTAssert(false, "request faild")
                exp.fulfill()
                return
            }

            if let json = json {
                if !json.isEmpty {
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

    func test_register_user() {
        let exp = expectation(description: "")
        self.signInUser {
            XCTAssert(true)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_get_newest_snaps() {
        let exp = expectation(description: "")
        self.signInUser {

            SnapsManager.sharedInstance.getSnaps(hottest: false, completion: { (error, snapsResult) in
                if let error = error {
                    XCTAssert(false, error.description)
                } else {
                    if let snapsResult = snapsResult, !snapsResult.isEmpty {
                        if let firstSnap = snapsResult.first, let _ = firstSnap.identifier {
                            XCTAssert(true)
                        } else {
                            XCTAssert(false, "snaps must be not empty")
                        }
                    } else {
                        XCTAssert(false, "snaps must be not empty")
                    }
                }
                exp.fulfill()
            })
        }
        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_get_hottest_snaps() {
        let exp = expectation(description: "")
        self.signInUser {

            SnapsManager.sharedInstance.getSnaps(hottest: true, completion: { (error, snapsResult) in
                if let error = error {
                    XCTAssert(false, error.description)
                } else {
                    if let snapsResult = snapsResult, !snapsResult.isEmpty {
                        if let firstSnap = snapsResult.first, let snapId = firstSnap.identifier {
                            SnapsManager.sharedInstance.getSnaps(hottest: true, page: 2, completion: { (_, snapsResultSecondPage) in
                                if let firstSnapSecondPage = snapsResultSecondPage?.first, let snapIdSecondPage = firstSnapSecondPage.identifier {
                                    if snapId != snapIdSecondPage {
                                        XCTAssert(true)
                                    } else {
                                        XCTAssert(false, "second query result contains duplicated data")
                                    }
                                } else {
                                    XCTAssert(false, "second query result was empty")
                                }
                                exp.fulfill()
                            })

                        } else {
                            XCTAssert(false, "snaps must be not empty")
                        }
                    } else {
                        XCTAssert(false, "snaps must be not empty")
                    }
                }
            })
        }
        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_get_newest_nearby_snaps() {
        let exp = expectation(description: "")
        let lat = -34.907000
        let lng = -56.190005
        self.signInUser {

            SnapsManager.sharedInstance.getSnaps(hottest: false, page: 1,
                                                 latitude: lat,
                                                 longitude: lng,
                                                 radius: 1609,
                                                 completion: { (error, snapsResult) in
                if let error = error {
                    XCTAssert(false, error.description)
                } else {
                    if let snapsResult = snapsResult, !snapsResult.isEmpty {
                        if let firstSnap = snapsResult.first, let _ = firstSnap.identifier {
                            let distance = MapHelper.distanceInMettersBetween(location1: (lat, lng), location2: (firstSnap.location.0, firstSnap.location.1))
                            if distance < 2000 {
                                XCTAssert(true)
                            } else {
                                XCTAssert(false, "seems that the first snap is not even close")
                            }

                        } else {
                            XCTAssert(false, "snaps must be not empty")
                        }
                    } else {
                        XCTAssert(false, "snaps must be not empty")
                    }
                }
                                                    exp.fulfill()
            })
        }
        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_report_snap() {
        let exp = expectation(description: "")
        self.signInUser {
            SnapsManager.sharedInstance.getSnaps(completion: { (error, snaps) in
                if let snap = snaps?.last {
                    SnapsManager.sharedInstance.reportSnap(snap: snap, completion: { (error) in
                        if let error = error {
                            if error.code == OKJuxError.ErrorType.duplicatedAction.rawValue {
                                XCTAssert(true)
                            } else {
                                XCTAssert(false, "error reporting snap \(error.localizedDescription)")
                            }
                        } else {
                            XCTAssert(true)
                        }
                        exp.fulfill()
                    })
                } else {
                    XCTAssert(false, "error while getting snaps")
                    exp.fulfill()
                }
            })

        }

        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_like_snap() {
        let exp = expectation(description: "")

        func like(snap: Snap, like: Bool, completion: @escaping (_ duplicatedAction: Bool) -> Void) {
            SnapsManager.sharedInstance.likeSnap(snap: snap, like: like, completion: { (error) in
                if let error = error {
                    if error.code == OKJuxError.ErrorType.duplicatedAction.rawValue {
                        completion(true)
                    } else {
                        XCTAssert(false, "error ranking a snap \(error.localizedDescription)")
                    }
                } else {
                    completion(false)
                }
            })
        }

        self.signInUser {
            SnapsManager.sharedInstance.getSnaps(completion: { (_, snaps) in
                if let snap = snaps?.last {

                    like(snap: snap, like: true, completion: { (duplicatedAction) in
                        if duplicatedAction {
                            like(snap: snap, like: false, completion: { (duplicatedAction) in
                                if duplicatedAction {
                                    XCTAssert(false, "both like/unlike actions returns 422")
                                }
                                exp.fulfill()
                            })
                        } else {
                            like(snap: snap, like: false, completion: { (duplicatedAction) in
                                if duplicatedAction {
                                    XCTAssert(false, "both like/unlike actions returns 422")
                                }
                                exp.fulfill()
                            })
                        }
                    })

                } else {
                    XCTAssert(false, "error while getting snaps")
                    exp.fulfill()
                }
            })

        }

        waitForExpectations(timeout: 115) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

}
