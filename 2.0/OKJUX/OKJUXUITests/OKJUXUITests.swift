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

    func waitFor(element: XCUIElement, disappears: Bool = false) -> Void {
        let strDisappear = disappears ? "false" : "true"
        let exists = NSPredicate(format: "exists == \(strDisappear)")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

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

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func atestExample() {
        //1 - check if there is at least one snap
        //2 - check failing getting snaps
        //3 - favorite button appears
        //4 - check if the content changes when I change the location
        //5 - don't crash if there is none
        //6 - how much favorites a snaps have (could be 0 or more)
    }

    func test_snapsView() {
        app.launchArguments.append("Mock-1,2")
        app.launch()

        let loading = app.toolbars.staticTexts["Loading Snaps"]
        self.waitFor(element: loading, disappears: true)
        XCTAssertTrue(app.collectionViews["Snaps collection"].cells.element(boundBy: 0).buttons["favorite snap"].exists, "hear button is not appering")

    }
    
}
