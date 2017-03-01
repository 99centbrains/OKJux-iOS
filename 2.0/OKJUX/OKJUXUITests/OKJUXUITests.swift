//
//  OKJUXUITests.swift
//  OKJUXUITests
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import XCTest
@testable import OKJUX

class OKJUXUITests: XCTestCase {

    let app = XCUIApplication()

    func waitFor(element: XCUIElement, disappears: Bool = false) {
        let strDisappear = disappears ? "false" : "true"
        let exists = NSPredicate(format: "exists == \(strDisappear)")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 15, handler: nil)

        if disappears {
            XCTAssertFalse(element.exists)
        } else {
            XCTAssertTrue(element.exists)
        }
    }



    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

        // In UI tests it’s important to set the initial state - such as interface orientation - 
        // required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func mockUserLogin() {
        let mockUserLogin = MockRequestItem(requestPath: "/api/v1/users",
                                            responseFileName: "post_user_mock",
                                            responseHTTPCode: 200,
                                            removeAfterCalled: true)
        app.launchArguments.append(mockUserLogin.toJsonString())
    }

    func mockNewestSnaps() {
        let mockNewestSnaps = MockRequestItem(requestPath: "/api/v1/snaps",
                                              responseFileName: "get_snaps_mock",
                                              responseHTTPCode: 200,
                                              removeAfterCalled: true)
        app.launchArguments.append(mockNewestSnaps.toJsonString())
    }

    func mockHottestSnaps() {
        let mockHotSnaps = MockRequestItem(requestPath: "/api/v1/snaps",
                                              responseFileName: "get_hottest_snaps_mock",
                                              responseHTTPCode: 200,
                                              removeAfterCalled: true)
        app.launchArguments.append(mockHotSnaps.toJsonString())
    }

    func test_snaps_newest_list() {
        self.mockUserLogin()
        self.mockNewestSnaps()
        app.launch()

        let loading = app.toolbars.staticTexts["Loading Snaps"]
        self.waitFor(element: loading, disappears: true)
        let newestSnapsCollection = app.collectionViews["Snaps collection newest"]

        let firstNewestCollectionCell = newestSnapsCollection.cells.element(boundBy: 0)
        XCTAssertTrue(firstNewestCollectionCell.exists, "unable to find the first cell")

        XCTAssertTrue(firstNewestCollectionCell.buttons["I like it"].exists, "hear button is not appering")
        XCTAssertTrue(firstNewestCollectionCell.staticTexts["Likes count"].exists, "likes count is not appering")
        if let strLikesCount = firstNewestCollectionCell.staticTexts["Likes count"].value as? String,
            let likesCount = Int(strLikesCount) {
            if likesCount != 99 {
                XCTAssert(false, "the likes count is not the correct one")
            }
        } else {
            XCTAssert(false, "unable to get the likes count")
        }
        XCTAssertTrue(firstNewestCollectionCell.buttons["Report abuse"].exists, "abuse button is not appering")

        let locationAndTimeLabel = firstNewestCollectionCell.staticTexts["Snap location and time ago"]
        waitFor(element: locationAndTimeLabel)
        XCTAssertTrue(locationAndTimeLabel.exists, "location text is not appering")
        guard let locationAndTimeLabelValue = locationAndTimeLabel.value as? String else {
            XCTAssert(false, "time and location label doesn't have a value")
            return
        }
        XCTAssertTrue(locationAndTimeLabelValue.contains("Uruguay"), "wasn't able to find the snap location")
        XCTAssertTrue(locationAndTimeLabelValue.contains("ago") ||
            locationAndTimeLabelValue.contains("week") ||
            locationAndTimeLabelValue.contains("year") ||
            locationAndTimeLabelValue.contains("month"), "wasn't able to find the snap time")
        XCTAssertTrue(firstNewestCollectionCell.images["Snap photo"].exists, "unable to find the email")
    }

    func test_snaps_hottest_list() {
        self.mockUserLogin()
        self.mockHottestSnaps()
        self.mockNewestSnaps()
        app.launch()

        let loading = app.toolbars.staticTexts["Loading Snaps"]
        self.waitFor(element: loading, disappears: true)
        let newestSnapsCollection = app.collectionViews["Snaps collection newest"]
        let hottestSnapsCollection = app.collectionViews["Snaps collection hottest"]
        newestSnapsCollection.swipeLeft()
        self.waitFor(element: loading, disappears: true)

        let firstHottestCollectionCell = hottestSnapsCollection.cells.element(boundBy: 0)
        XCTAssertTrue(firstHottestCollectionCell.exists, "unable to find the first cell")

        XCTAssertTrue(firstHottestCollectionCell.buttons["I like it"].exists, "hear button is not appering")
        XCTAssertTrue(firstHottestCollectionCell.staticTexts["Likes count"].exists, "likes count is not appering")
        if let strLikesCount = firstHottestCollectionCell.staticTexts["Likes count"].value as? String,
            let likesCount = Int(strLikesCount) {
            if likesCount != 220 {
                XCTAssert(false, "the likes count is not the correct one")
            }
        } else {
            XCTAssert(false, "unable to get the likes count")
        }
        XCTAssertFalse(firstHottestCollectionCell.buttons["Report abuse"].exists, "abuse button should be hidden")
        let locationAndTimeLabel = firstHottestCollectionCell.staticTexts["Snap location and time ago"]
        XCTAssertFalse(locationAndTimeLabel.exists, "location text should not appear")
        XCTAssertTrue(firstHottestCollectionCell.images["Snap photo"].exists, "unable to find the email")
    }

    func test_snaps_list_error_500() {
        let mockSnapsError500 = MockRequestItem(requestPath: "/api/v1/snaps",
                                            responseFileName: "get_snaps_mock",
                                            responseHTTPCode: 500,
                                            removeAfterCalled: true)
        app.launchArguments.append(mockSnapsError500.toJsonString())
        app.launch()
        waitFor(element: app.staticTexts["Error"])
        waitFor(element: app.staticTexts["Oops, there was an error trying get the snaps. please try again later."])
    }

    func test_snaps_list_error_empty() {
        app.launchArguments.append("Mock-4")
        app.launch()
        waitFor(element: app.staticTexts["Error"])
        waitFor(element: app.staticTexts["Oops, there was an error trying get the snaps. please try again later."])
    }

    func test_landing_expand_map() {
        self.mockUserLogin()
        self.mockHottestSnaps()
        self.mockNewestSnaps()
        app.launch()
        let loading = app.toolbars.staticTexts["Loading Snaps"]
        waitFor(element: loading, disappears: true)
        let map = app.otherElements["Snaps map"]
        XCTAssertTrue((map.value as? String) == "collapsed", "the map is not being collapsed")

        let firstCell = app.collectionViews["Snaps collection newest"].cells.element(boundBy: 0)
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 6))
        start.press(forDuration: 0, thenDragTo: finish)

        //TODO: Need to close the map instead of kill the app
        app.terminate()

        self.mockUserLogin()
        self.mockHottestSnaps()
        self.mockNewestSnaps()
        app.launch()
        self.waitFor(element: loading, disappears: true)
        let map2 = app.otherElements["Snaps map"]
        map2.tap()
        XCTAssertTrue((map2.value as? String) == "expanded", "the map is not being expanded")
    }

    func test_switching_between_newest_and_hottest() {
        self.mockUserLogin()
        self.mockHottestSnaps()
        self.mockNewestSnaps()
        app.launch()
        let loading = app.toolbars.staticTexts["Loading Snaps"]
        waitFor(element: loading, disappears: true)

        let hottest = app.collectionViews["Snaps collection hottest"]
        let newest = app.collectionViews["Snaps collection newest"]

        XCTAssertFalse(hottest.exists, "Hottest should not be visible")
        app.buttons["Hottest"].tap()

        self.waitFor(element: newest, disappears: true)
        XCTAssertTrue(hottest.exists, "Hottest should be visible")
        XCTAssertFalse(newest.exists, "Newest should not be visible")

        app.buttons["Newest"].tap()
        self.waitFor(element: hottest, disappears: true)
        XCTAssertTrue(newest.exists, "Newest should be visible")

        newest.swipeRight()
        XCTAssertTrue(newest.exists, "swiping left should not change to hotest")
        newest.swipeLeft()
        self.waitFor(element: newest, disappears: true)
        XCTAssertFalse(newest.exists, "Newest should NOT be visible")
        XCTAssertTrue(hottest.exists, "Hottest should be visible")
        hottest.swipeRight()
        XCTAssertTrue(newest.exists, "swiping left should not change to hotest")
    }

    func test_report_snap() {

        self.mockUserLogin()
        self.mockNewestSnaps()
        let mockSuccess = MockRequestItem(requestPath: "/api/v1/snaps/13666/flag", responseFileName: "", responseHTTPCode: 204, removeAfterCalled: true)
        let mockAlearyReported = MockRequestItem(requestPath: "/api/v1/snaps/13666/flag", responseFileName: "", responseHTTPCode: 422, removeAfterCalled: true)
        let mockFail = MockRequestItem(requestPath: "/api/v1/snaps/13666/flag", responseFileName: "", responseHTTPCode: 500, removeAfterCalled: true)

        app.launchArguments.append(mockFail.toJsonString())
        app.launchArguments.append(mockAlearyReported.toJsonString())
        app.launchArguments.append(mockSuccess.toJsonString())
        app.launch()
        let loading = app.toolbars.staticTexts["Loading Snaps"]
        waitFor(element: loading, disappears: true)

        let snapsCollection = app.collectionViews["Snaps collection newest"]
        let firstCell = snapsCollection.cells.element(boundBy: 0)
        let secondCell = snapsCollection.cells["cell_1"]
        let errorAlert = app.alerts["Error"]
        let reportPhotoAlert = app.alerts["Report Photo"]
        
        firstCell.buttons["Report abuse"].tap()
        XCTAssertTrue(reportPhotoAlert.exists, "The alert is not appearing")
        XCTAssertTrue(reportPhotoAlert.buttons["Report"].exists, "The alert does not contain the report button")
        XCTAssertTrue(reportPhotoAlert.buttons["Never Mind"].exists, "The alert does not contain the Never Mind button")

        reportPhotoAlert.buttons["Never Mind"].tap()
        XCTAssertFalse(reportPhotoAlert.exists, "The alert should be dismmissed")

        firstCell.buttons["Report abuse"].tap()
        reportPhotoAlert.buttons["Report"].tap()

        waitFor(element: app.staticTexts["Done"])
        XCTAssertTrue(app.staticTexts["Done"].exists, "The done message it's not appearing")

        firstCell.buttons["Report abuse"].tap()
        reportPhotoAlert.buttons["Report"].tap()

        waitFor(element: errorAlert.staticTexts["You have already reported this snap."])
        errorAlert.buttons["OK"].tap()

        firstCell.buttons["Report abuse"].tap()
        reportPhotoAlert.buttons["Report"].tap()

        waitFor(element: errorAlert.staticTexts["Oops! Try again later."])

        //Second cell is mocked as already reported
        snapsCollection.scrollToElement(element: secondCell)
        secondCell.buttons["Report abuse"].tap()
        waitFor(element: errorAlert.staticTexts["You have already reported this snap."])
        errorAlert.buttons["OK"].tap()

    }

}

extension XCUIElement {

    internal func scrollToElement(element: XCUIElement) {
        while !element.exists {
            swipeUp()
        }
    }

}
