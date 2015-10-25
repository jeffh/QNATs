import XCTest
import Nimble
@testable import tvOS_Cocoapods

class NimbleIntegrationUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testExample() {
        expect(1).to(equal(1))

        let window = XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0)
        let textView = window.childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element
        expect(textView.value as? String).to(equal("expected to equal <2>, got <1>"))
    }
    
}
