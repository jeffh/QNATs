import XCTest
import Nimble

class NimbleIntegrationUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testExample() {
        expect(1).to(equal(1))
        let textView = XCUIApplication().windows["Window"].scrollViews.childrenMatchingType(.TextView).element
        expect(textView.value as? String).to(equal("expected to equal <2>, got <1>"))
    }
}
