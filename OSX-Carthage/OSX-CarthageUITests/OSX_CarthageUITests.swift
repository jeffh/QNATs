//
//  OSX_CarthageUITests.swift
//  OSX-CarthageUITests
//
//  Created by Jeff Hui on 9/30/15.
//  Copyright © 2015 Jeff Hui. All rights reserved.
//

import XCTest
import Nimble

class OSX_CarthageUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        expect(1).to(equal(1))

        let textView = XCUIApplication().windows["Window"].scrollViews.childrenMatchingType(.TextView).element
        expect(textView.value as? String).to(equal("expected to equal <2>, got <1>"))
    }
    
}
