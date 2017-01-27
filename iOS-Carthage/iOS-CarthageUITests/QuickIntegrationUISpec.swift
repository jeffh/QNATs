import Quick
import Nimble

class QuickIntegrationUISpec: QuickSpec {
    override func setUp() {
        continueAfterFailure = false
    }

    override func spec() {
        describe("Running with as UI Tests") {
            beforeEach {
                XCUIApplication().launch()
            }

            it("should work") {
                expect(1).to(equal(1))

                let window = XCUIApplication().children(matching: .window).element(boundBy: 0)
                let textView = window.children(matching: .other).element.children(matching: .textView).element
                expect(textView.value as? String).to(equal("expected to equal <2>, got <1>"))
            }
        }
    }
}
