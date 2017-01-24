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

        let window = XCUIApplication().children(matching: .window).element(boundBy: 0)
        let textView = window.children(matching: .other).element.children(matching: .textView).element
        expect(textView).toNot(beNil())
    }
    
}
