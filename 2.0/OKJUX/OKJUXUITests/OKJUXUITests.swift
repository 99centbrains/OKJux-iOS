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

    func test_snaps_newest_list() {
        app.launchArguments.append("Mock-1,2")
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
            locationAndTimeLabelValue.contains("year") ||
            locationAndTimeLabelValue.contains("month"), "wasn't able to find the snap time")
        XCTAssertTrue(firstNewestCollectionCell.images["Snap photo"].exists, "unable to find the email")
    }

    func test_snaps_hottest_list() {
        app.launchArguments.append("Mock-1,5")
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
        app.launchArguments.append("Mock-3")
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
        app.launchArguments.append("Mock-1,2")
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

        app.launchArguments.append("Mock-1,2")
        app.launch()
        self.waitFor(element: loading, disappears: true)
        let map2 = app.otherElements["Snaps map"]
        map2.tap()
        XCTAssertTrue((map2.value as? String) == "expanded", "the map is not being expanded")
    }

    func test_switching_between_newest_and_hottest() {
        app.launchArguments.append("Mock-1,2")
        app.launch()
        let loading = app.toolbars.staticTexts["Loading Snaps"]
        waitFor(element: loading, disappears: true)

        let hottest = app.collectionViews["Snaps collection hottest"]
        let newest = app.collectionViews["Snaps collection newest"]

        XCTAssertFalse(hottest.exists, "Hottest should not be visible")
        app.buttons["Hottest\t"].tap()

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

}
