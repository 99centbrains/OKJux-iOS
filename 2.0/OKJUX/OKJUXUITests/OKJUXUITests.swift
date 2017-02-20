//
//  OKJUXUITests.swift
//  OKJUXUITests
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import XCTest

class OKJUXUITests: XCTestCase {

    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        Thread.sleep(forTimeInterval: 1)
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        //1 - check if there is at least one snap
        //2 - check failing getting snaps
        //3 - favorite button appears
        //4 - check if the content changes when I change the location
        //5 - don't crash if there is none
        //6 - how much favorites a snaps have (could be 0 or more)

        XCUIApplication().toolbars.staticTexts["Loading Snaps"].tap()
        //TODO: no termine con esto, hay que hacer una funcion que espera a que desaparezca el loading, y después corra el test siguiente.

        

    }

    func test_snapsView() {
        XCTAssertTrue(app.collectionViews["Snaps collection"].cells.element(boundBy: 0).buttons["favorite snap"].exists, "hear button is not appering")
    }
    
}
