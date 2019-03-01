//
//  BSTextDemoUITests.swift
//  BSTextDemoUITests
//
//  Created by BlueSky on 2019/1/23.
//  Copyright © 2019 GeekBruce. All rights reserved.
//

import XCTest
import BSTextDemo

class BSTextDemoUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        app.terminate()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        app.tables.firstMatch.cells.firstMatch.tap()
        sleep(2)
        app.buttons.firstMatch.tap()
        sleep(2)
        app.tables.firstMatch.cells.element(boundBy: 1).tap()
        sleep(2)
        app.buttons.firstMatch.tap()
        
        print("abc")
    }

}
